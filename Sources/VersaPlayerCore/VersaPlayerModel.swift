//
//  VersaPlayerModel.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import Observation

/// Observable wrapper around `AVPlayer`.
@MainActor
@Observable
public final class VersaPlayerModel {
    public enum Status: Sendable, Equatable {
        case idle
        case loading
        case ready
        case failed(PlaybackError)
    }

    /// The underlying player.
    public let player: AVPlayer

    public private(set) var status: Status = .idle
    public private(set) var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    public private(set) var rate: Float = 0
    /// Seconds. Follows the scrub position while scrubbing.
    public private(set) var currentTime: TimeInterval = 0
    /// Seconds. 0 until known and for live streams.
    public private(set) var duration: TimeInterval = 0
    public private(set) var isLive = false
    /// End of the buffered range at the playhead, in seconds.
    public private(set) var bufferedTime: TimeInterval = 0
    public private(set) var isScrubbing = false
    public private(set) var tracks: [MediaTrack] = []
    public private(set) var selectedTracks: [MediaTrack.Kind: MediaTrack] = [:]
    public private(set) var currentItem: VersaPlayerItem?
    public private(set) var canPlayFastForward = false
    public private(set) var canPlayReverse = false
    public private(set) var isExternalPlaybackActive = false
    public internal(set) var isPictureInPicturePossible = false
    public internal(set) var isPictureInPictureActive = false

    /// Playing, waiting to play, or scrubbing and resuming after.
    public var isPlaying: Bool { timeControlStatus != .paused || (isScrubbing && wasPlayingBeforeScrub) }
    public var isBuffering: Bool { timeControlStatus == .waitingToPlayAtSpecifiedRate }

    /// Asked once before each `play()`. Return `false` to block playback.
    @ObservationIgnored
    public var shouldBeginPlayback: (@MainActor (VersaPlayerModel) async -> Bool)?

    /// A new event stream on each read.
    public var events: AsyncStream<PlaybackEvent> { broadcaster.stream() }

    @ObservationIgnored private let broadcaster = EventBroadcaster<PlaybackEvent>()
    @ObservationIgnored private let playerObservers = ObserverBag()
    @ObservationIgnored private var itemObservers = ObserverBag()
    @ObservationIgnored private var playerItem: AVPlayerItem?
    @ObservationIgnored private var selectionIndex = MediaSelectionIndex()
    @ObservationIgnored private var trackTask: Task<Void, Never>?
    @ObservationIgnored private var keyHandler: ContentKeySessionHandler?
    @ObservationIgnored private var pendingStartTime: TimeInterval?
    private var wasPlayingBeforeScrub = false
    @ObservationIgnored private var seekInFlight = false
    @ObservationIgnored private var pendingSeek: TimeInterval?
    @ObservationIgnored private var plugins: [any VersaPlayerPlugin] = []
    @ObservationIgnored var pictureInPicture: PictureInPictureCoordinator?

    public init(player: AVPlayer = AVPlayer()) {
        self.player = player
        observePlayer()
    }

    /// Replaces the current item.
    public func load(_ item: VersaPlayerItem, autoplay: Bool = true) {
        unloadCurrentItem()

        let asset = AVURLAsset(url: item.url)
        if let drm = item.drm {
            let handler = ContentKeySessionHandler(provider: drm.provider, asset: asset)
            handler.onError = { [weak self] error in
                let model = self
                onMain { model?.fail(Self.contentKeyError(error)) }
            }
            keyHandler = handler
        }

        let avItem = AVPlayerItem(asset: asset)
        item.quality.apply(to: avItem)
        if let buffer = item.preferredForwardBufferDuration {
            avItem.preferredForwardBufferDuration = buffer
        }
        avItem.textStyleRules = item.captionStyle?.textStyleRules

        currentItem = item
        playerItem = avItem
        pendingStartTime = item.startTime
        status = .loading
        observe(avItem)
        player.replaceCurrentItem(with: avItem)
        broadcaster.send(.itemLoaded(item.url))

        trackTask = Task { [weak self] in
            let index = await MediaSelectionIndex.load(from: asset)
            guard let self, !Task.isCancelled, self.playerItem === avItem else { return }
            self.selectionIndex = index
            self.tracks = index.tracks
            self.refreshSelection()
        }

        if autoplay { play() }
    }

    /// Removes the current item.
    public func unload() {
        unloadCurrentItem()
        status = .idle
    }

    private func unloadCurrentItem() {
        trackTask?.cancel()
        trackTask = nil
        itemObservers = ObserverBag()
        keyHandler?.invalidate()
        keyHandler = nil
        player.replaceCurrentItem(with: nil)
        playerItem = nil
        currentItem = nil
        selectionIndex = MediaSelectionIndex()
        tracks = []
        selectedTracks = [:]
        currentTime = 0
        duration = 0
        bufferedTime = 0
        isLive = false
        isScrubbing = false
        wasPlayingBeforeScrub = false
        canPlayFastForward = false
        canPlayReverse = false
        pendingStartTime = nil
        pendingSeek = nil
    }

    public func play() {
        guard playerItem != nil else { return }
        guard let gate = shouldBeginPlayback else {
            player.play()
            return
        }
        Task {
            if await gate(self) { self.player.play() }
        }
    }

    public func pause() {
        player.pause()
    }

    public func togglePlayback() {
        if isScrubbing {
            wasPlayingBeforeScrub.toggle()
        } else if isPlaying || rate != 0 {
            pause()
        } else {
            play()
        }
    }

    /// Sets the rate. Ignored when the item can't play at it.
    public func setRate(_ newRate: Float) {
        guard playerItem != nil else { return }
        if newRate < 0 && !canPlayReverse { return }
        if newRate > 2 && !canPlayFastForward { return }
        player.rate = newRate
    }

    /// Returns `false` if interrupted by another seek.
    @discardableResult
    public func seek(to seconds: TimeInterval) async -> Bool {
        let target = clamp(seconds)
        currentTime = target
        let player = player
        return await withCheckedContinuation { continuation in
            player.seek(to: Self.cmTime(target), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                continuation.resume(returning: finished)
            }
        }
    }

    public func skip(by delta: TimeInterval) {
        Task { await seek(to: currentTime + delta) }
    }

    /// Pauses until `endScrubbing()`.
    public func beginScrubbing() {
        guard !isScrubbing else { return }
        wasPlayingBeforeScrub = timeControlStatus != .paused || rate != 0
        isScrubbing = true
        player.pause()
    }

    /// Coalesces seeks so only the latest position is chased.
    public func scrub(to seconds: TimeInterval) {
        let target = clamp(seconds)
        currentTime = target
        if seekInFlight {
            pendingSeek = target
        } else {
            performScrubSeek(target)
        }
    }

    public func endScrubbing() {
        guard isScrubbing else { return }
        isScrubbing = false
        if wasPlayingBeforeScrub { play() }
        wasPlayingBeforeScrub = false
    }

    private func performScrubSeek(_ target: TimeInterval) {
        seekInFlight = true
        player.seek(to: Self.cmTime(target), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            let model = self
            onMain {
                guard let model else { return }
                if let next = model.pendingSeek {
                    model.pendingSeek = nil
                    model.performScrubSeek(next)
                } else {
                    model.seekInFlight = false
                }
            }
        }
    }

    public func tracks(of kind: MediaTrack.Kind) -> [MediaTrack] {
        tracks.filter { $0.kind == kind }
    }

    public func select(_ track: MediaTrack) {
        guard let playerItem, let group = selectionIndex.group(for: track.kind),
              let option = selectionIndex.option(for: track) else { return }
        playerItem.select(option, in: group)
        refreshSelection()
    }

    /// Turns a kind off when the stream allows it.
    public func deselect(_ kind: MediaTrack.Kind) {
        guard let playerItem, let group = selectionIndex.group(for: kind),
              selectionIndex.allowsEmptySelection(kind) else { return }
        playerItem.select(nil, in: group)
        refreshSelection()
    }

    public func setCaptionStyle(_ style: CaptionStyle?) {
        currentItem?.captionStyle = style
        playerItem?.textStyleRules = style?.textStyleRules
    }

    public func setQuality(_ quality: QualityPreference) {
        currentItem?.quality = quality
        if let playerItem { quality.apply(to: playerItem) }
    }

    private func refreshSelection() {
        guard let playerItem else { return }
        selectedTracks = selectionIndex.selection(in: playerItem)
    }

    public func add(_ plugin: any VersaPlayerPlugin) {
        guard !plugins.contains(where: { $0 === plugin }) else { return }
        plugins.append(plugin)
        plugin.attach(to: self)
    }

    public func remove(_ plugin: any VersaPlayerPlugin) {
        guard let index = plugins.firstIndex(where: { $0 === plugin }) else { return }
        plugins.remove(at: index)
        plugin.detach(from: self)
    }

    public func plugin<P: VersaPlayerPlugin>(of type: P.Type) -> P? {
        plugins.lazy.compactMap { $0 as? P }.first
    }

    private func observePlayer() {
        let bag = playerObservers
        bag.add(player.observe(\.timeControlStatus, options: [.new]) { @Sendable [weak self] player, _ in
            let value = player.timeControlStatus
            let model = self
            onMain { model?.apply(timeControlStatus: value) }
        })
        bag.add(player.observe(\.rate, options: [.new]) { @Sendable [weak self] player, _ in
            let value = player.rate
            let model = self
            onMain { model?.rate = value }
        })
        bag.add(player.observe(\.status, options: [.new]) { @Sendable [weak self] player, _ in
            guard player.status == .failed else { return }
            let error = player.error
            let model = self
            onMain { model?.fail(error.map(PlaybackError.init) ?? .underlying(domain: "VersaPlayer", code: -1, message: "Player failed")) }
        })
        #if !os(visionOS)
        bag.add(player.observe(\.isExternalPlaybackActive, options: [.new]) { @Sendable [weak self] player, _ in
            let value = player.isExternalPlaybackActive
            let model = self
            onMain { model?.isExternalPlaybackActive = value }
        })
        #endif
        let token = player.addPeriodicTimeObserver(forInterval: Self.cmTime(0.5), queue: .main) { [weak self] time in
            let model = self
            MainActor.assumeIsolated {
                guard let model, !model.isScrubbing, !model.seekInFlight, time.isNumeric else { return }
                model.currentTime = time.seconds
            }
        }
        bag.setTimeObserver(token, on: player)
    }

    private func observe(_ item: AVPlayerItem) {
        let bag = ObserverBag()
        bag.add(item.observe(\.status, options: [.initial, .new]) { @Sendable [weak self] item, _ in
            let status = item.status
            let error = item.error
            let model = self
            onMain { model?.apply(itemStatus: status, error: error) }
        })
        bag.add(item.observe(\.duration, options: [.initial, .new]) { @Sendable [weak self] item, _ in
            let duration = item.duration
            let model = self
            onMain { model?.apply(duration: duration) }
        })
        bag.add(item.observe(\.loadedTimeRanges, options: [.new]) { @Sendable [weak self] item, _ in
            let current = item.currentTime().seconds
            let ranges = item.loadedTimeRanges.map(\.timeRangeValue)
            let end = ranges.first { $0.containsTime(CMTime(seconds: current, preferredTimescale: 600)) }
                .map { $0.end.seconds } ?? current
            let model = self
            onMain { model?.bufferedTime = end.isFinite ? end : 0 }
        })

        let center = NotificationCenter.default
        bag.add(center.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: item, queue: .main) { [weak self] _ in
            let model = self
            MainActor.assumeIsolated { model?.broadcaster.send(.ended) }
        })
        bag.add(center.addObserver(forName: AVPlayerItem.timeJumpedNotification, object: item, queue: .main) { [weak self] _ in
            let model = self
            MainActor.assumeIsolated { model?.broadcaster.send(.timeJumped) }
        })
        bag.add(center.addObserver(forName: AVPlayerItem.failedToPlayToEndTimeNotification, object: item, queue: .main) { [weak self] note in
            let error = note.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? any Error
            let model = self
            MainActor.assumeIsolated {
                model?.fail(error.map(PlaybackError.init) ?? .underlying(domain: "VersaPlayer", code: -2, message: "Failed to play to end"))
            }
        })
        bag.add(center.addObserver(forName: AVPlayerItem.mediaSelectionDidChangeNotification, object: item, queue: .main) { [weak self] _ in
            let model = self
            MainActor.assumeIsolated { model?.refreshSelection() }
        })
        itemObservers = bag
    }

    private func apply(timeControlStatus new: AVPlayer.TimeControlStatus) {
        let old = timeControlStatus
        guard old != new else { return }
        timeControlStatus = new
        if old == .waitingToPlayAtSpecifiedRate { broadcaster.send(.bufferingEnded) }
        switch new {
        case .playing: broadcaster.send(.playing)
        case .paused: broadcaster.send(.paused)
        case .waitingToPlayAtSpecifiedRate: broadcaster.send(.bufferingStarted)
        @unknown default: break
        }
    }

    private func apply(itemStatus: AVPlayerItem.Status, error: (any Error)?) {
        switch itemStatus {
        case .readyToPlay:
            guard status != .ready, let playerItem else { return }
            status = .ready
            canPlayFastForward = playerItem.canPlayFastForward
            canPlayReverse = playerItem.canPlayReverse
            apply(duration: playerItem.duration)
            if let start = pendingStartTime {
                pendingStartTime = nil
                Task { await seek(to: start) }
            }
            broadcaster.send(.ready)
        case .failed:
            fail(error.map(PlaybackError.init) ?? .underlying(domain: "VersaPlayer", code: -3, message: "Item failed"))
        default:
            break
        }
    }

    private func apply(duration time: CMTime) {
        guard status == .ready else { return }
        if time.isIndefinite {
            isLive = true
            duration = 0
        } else if time.isNumeric {
            isLive = false
            duration = time.seconds
        }
    }

    private func fail(_ error: PlaybackError) {
        if case .failed(error) = status { return }
        status = .failed(error)
        broadcaster.send(.failed(error))
    }

    private func clamp(_ seconds: TimeInterval) -> TimeInterval {
        guard seconds.isFinite else { return 0 }
        let lower = max(0, seconds)
        return duration > 0 ? min(lower, duration) : lower
    }

    nonisolated static func cmTime(_ seconds: TimeInterval) -> CMTime {
        CMTime(seconds: seconds, preferredTimescale: 600)
    }

    nonisolated private static func contentKeyError(_ error: any Error) -> PlaybackError {
        if let playbackError = error as? PlaybackError { return playbackError }
        return .contentKey(message: error.localizedDescription)
    }
}

/// Runs inline on the main thread, otherwise hops to the main actor.
func onMain(_ body: @escaping @MainActor @Sendable () -> Void) {
    if Thread.isMainThread {
        MainActor.assumeIsolated { body() }
    } else {
        Task { @MainActor in body() }
    }
}

/// Releases its observation tokens on deinit.
final class ObserverBag: @unchecked Sendable {
    private var observations: [NSKeyValueObservation] = []
    private var notificationTokens: [any NSObjectProtocol] = []
    private var timeObserver: (player: AVPlayer, token: Any)?

    func add(_ observation: NSKeyValueObservation) {
        observations.append(observation)
    }

    func add(_ token: any NSObjectProtocol) {
        notificationTokens.append(token)
    }

    func setTimeObserver(_ token: Any, on player: AVPlayer) {
        timeObserver = (player, token)
    }

    deinit {
        let cleanup = Cleanup(observations: observations, notificationTokens: notificationTokens, timeObserver: timeObserver)
        if Thread.isMainThread {
            cleanup.run()
        } else {
            DispatchQueue.main.async { cleanup.run() }
        }
    }

    private struct Cleanup: @unchecked Sendable {
        let observations: [NSKeyValueObservation]
        let notificationTokens: [any NSObjectProtocol]
        let timeObserver: (player: AVPlayer, token: Any)?

        func run() {
            observations.forEach { $0.invalidate() }
            notificationTokens.forEach { NotificationCenter.default.removeObserver($0) }
            if let timeObserver {
                timeObserver.player.removeTimeObserver(timeObserver.token)
            }
        }
    }
}
