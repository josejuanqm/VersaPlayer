//
//  NowPlaying.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import MediaPlayer
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

/// Publishes Now Playing info and handles remote commands (lock screen, Control Center, headphones).
public final class NowPlayingPlugin: VersaPlayerPlugin {
    public let skipInterval: TimeInterval

    private weak var model: VersaPlayerModel?
    private var eventTask: Task<Void, Never>?
    private var artworkTask: Task<Void, Never>?
    private var artwork: (url: URL, value: MPMediaItemArtwork)?
    private var commandTargets: [(MPRemoteCommand, Any)] = []
    private let infoCenter: MPNowPlayingInfoCenter
    private let commandCenter: MPRemoteCommandCenter

    public init(skipInterval: TimeInterval = 10) {
        self.skipInterval = skipInterval
        self.infoCenter = .default()
        self.commandCenter = .shared()
    }

    public func attach(to model: VersaPlayerModel) {
        self.model = model
        registerCommands()
        let events = model.events
        eventTask = Task { [weak self] in
            for await event in events {
                guard let self else { return }
                if case .timeJumped = event { self.update() }
            }
        }
        track()
    }

    private func track() {
        guard let model else { return }
        let url = withObservationTracking {
            _ = (model.status, model.isPlaying, model.isLive, model.duration)
            return model.currentItem?.metadata.artworkURL
        } onChange: { [weak self] in
            Task { @MainActor in self?.track() }
        }
        if url != artwork?.url { loadArtwork() }
        update()
    }

    public func detach(from model: VersaPlayerModel) {
        eventTask?.cancel()
        artworkTask?.cancel()
        commandTargets.forEach { $0.0.removeTarget($0.1) }
        commandTargets = []
        infoCenter.nowPlayingInfo = nil
        self.model = nil
    }

    func update() {
        guard let model, let item = model.currentItem else {
            infoCenter.nowPlayingInfo = nil
            return
        }
        var info: [String: Any] = [
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.video.rawValue,
            MPNowPlayingInfoPropertyIsLiveStream: model.isLive,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: model.player.currentTime().seconds.finiteOrZero,
            MPNowPlayingInfoPropertyPlaybackRate: model.isPlaying ? Double(model.player.rate) : 0,
            MPNowPlayingInfoPropertyDefaultPlaybackRate: 1.0,
            MPNowPlayingInfoPropertyAssetURL: item.url,
        ]
        if model.duration > 0 { info[MPMediaItemPropertyPlaybackDuration] = model.duration }
        if let title = item.metadata.title { info[MPMediaItemPropertyTitle] = title }
        if let subtitle = item.metadata.subtitle { info[MPMediaItemPropertyArtist] = subtitle }
        if let artwork, artwork.url == item.metadata.artworkURL { info[MPMediaItemPropertyArtwork] = artwork.value }
        infoCenter.nowPlayingInfo = info
        #if os(macOS)
        infoCenter.playbackState = model.isPlaying ? .playing : .paused
        #endif
    }

    private func loadArtwork() {
        artworkTask?.cancel()
        guard let url = model?.currentItem?.metadata.artworkURL else { return }
        artworkTask = Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let value = Self.makeArtwork(data),
                  let self, !Task.isCancelled else { return }
            self.artwork = (url, value)
            self.update()
        }
    }

    nonisolated private static func makeArtwork(_ data: Data) -> MPMediaItemArtwork? {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        #else
        guard let image = NSImage(data: data) else { return nil }
        #endif
        return MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }

    private func registerCommands() {
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: skipInterval)]
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: skipInterval)]
        addTarget(commandCenter.playCommand) { $0.play() }
        addTarget(commandCenter.pauseCommand) { $0.pause() }
        addTarget(commandCenter.togglePlayPauseCommand) { $0.togglePlayback() }
        addTarget(commandCenter.skipForwardCommand) { [skipInterval] in $0.skip(by: skipInterval) }
        addTarget(commandCenter.skipBackwardCommand) { [skipInterval] in $0.skip(by: -skipInterval) }
        addTarget(commandCenter.changePlaybackPositionCommand) { model, event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return }
            Task { await model.seek(to: event.positionTime) }
        }
    }

    private func addTarget(_ command: MPRemoteCommand, _ action: @escaping @MainActor (VersaPlayerModel) -> Void) {
        addTarget(command) { model, _ in action(model) }
    }

    private func addTarget(_ command: MPRemoteCommand, _ action: @escaping @MainActor (VersaPlayerModel, MPRemoteCommandEvent) -> Void) {
        command.isEnabled = true
        let token = command.addTarget { [weak self] event in
            nonisolated(unsafe) let event = event
            return MainActor.assumeIsolated {
                guard let model = self?.model, model.currentItem != nil else { return .noActionableNowPlayingItem }
                action(model, event)
                return .success
            }
        }
        commandTargets.append((command, token))
    }
}

private extension Double {
    var finiteOrZero: Double { isFinite ? self : 0 }
}
