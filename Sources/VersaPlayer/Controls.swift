//
//  Controls.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import AVKit
import SwiftUI


public struct PlayPauseButton: View {
    @Environment(\.versaPlayer) private var model
    @Environment(ControlsVisibility.self) private var visibility: ControlsVisibility?

    public init() {}

    public var body: some View {
        if let model {
            Button {
                model.togglePlayback()
                visibility?.interact()
            } label: {
                Image(systemName: model.isPlaying ? "pause.fill" : "play.fill")
                    .contentTransition(.symbolEffect(.replace))
            }
            .accessibilityLabel(model.isPlaying ? "Pause" : "Play")
        }
    }
}

public struct SkipButton: View {
    @Environment(\.versaPlayer) private var model
    @Environment(ControlsVisibility.self) private var visibility: ControlsVisibility?
    private let seconds: TimeInterval

    public init(seconds: TimeInterval) {
        self.seconds = seconds
    }

    public var body: some View {
        if let model {
            Button {
                model.skip(by: seconds)
                visibility?.interact()
            } label: {
                Image(systemName: Self.symbol(for: seconds))
            }
            .accessibilityLabel(seconds < 0 ? "Back \(Int(-seconds)) seconds" : "Forward \(Int(seconds)) seconds")
        }
    }

    nonisolated static func symbol(for seconds: TimeInterval) -> String {
        let base = seconds < 0 ? "gobackward" : "goforward"
        let amount = Int(abs(seconds))
        return [5, 10, 15, 30, 45, 60, 75, 90].contains(amount) ? "\(base).\(amount)" : base
    }
}

/// Toggles between `rate` and normal playback.
public struct RateButton: View {
    @Environment(\.versaPlayer) private var model
    @Environment(ControlsVisibility.self) private var visibility: ControlsVisibility?
    private let rate: Float

    public init(rate: Float) {
        self.rate = rate
    }

    public var body: some View {
        if let model {
            let active = model.rate == rate
            Button {
                if active { model.setRate(1) } else { model.setRate(rate) }
                visibility?.interact()
            } label: {
                Image(systemName: rate < 0 ? "backward.fill" : "forward.fill")
                    .symbolVariant(active ? .circle : .none)
            }
            .disabled(rate < 0 ? !model.canPlayReverse : (rate > 2 && !model.canPlayFastForward))
            .accessibilityLabel(rate < 0 ? "Rewind" : "Fast forward")
        }
    }
}

/// Seek bar. On tvOS, focus it and press left/right to scrub; select commits.
public struct Scrubber: View {
    @Environment(\.versaPlayer) private var model
    @Environment(ControlsVisibility.self) private var visibility: ControlsVisibility?

    public init() {}

    public var body: some View {
        if let model {
            let upperBound = max(model.duration, 0.001)
            #if os(tvOS)
            TVScrubBar(model: model, visibility: visibility)
            #else
            Slider(
                value: Binding(
                    get: { min(model.currentTime, upperBound) },
                    set: { model.scrub(to: $0) }
                ),
                in: 0...upperBound,
                onEditingChanged: { editing in
                    editing ? model.beginScrubbing() : model.endScrubbing()
                    visibility?.interact()
                }
            )
            .disabled(model.duration <= 0)
            .accessibilityLabel("Playback position")
            #endif
        }
    }
}

#if os(tvOS)
private struct TVScrubBar: View {
    let model: VersaPlayerModel
    let visibility: ControlsVisibility?
    @State private var stepper = ScrubStepper()
    @State private var commitTask: Task<Void, Never>?

    var body: some View {
        ScrubTrack(progress: progress, onFocusChange: { focused in
            if !focused { commit() }
        })
        .focusable()
        .focusEffectDisabled()
        .onMoveCommand { direction in
            switch direction {
            case .left: move(-1)
            case .right: move(1)
            default: break
            }
        }
        .onTapGesture {
            if model.isScrubbing { commit() } else { model.togglePlayback() }
            visibility?.interact()
        }
        .accessibilityLabel("Playback position")
        .accessibilityValue(TimeLabel.format(model.currentTime))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: move(1)
            case .decrement: move(-1)
            @unknown default: break
            }
        }
    }

    private var progress: Double {
        guard model.duration > 0, model.currentTime.isFinite else { return 0 }
        return min(max(model.currentTime / model.duration, 0), 1)
    }

    private func move(_ direction: Double) {
        guard model.duration > 0 else { return }
        if !model.isScrubbing { model.beginScrubbing() }
        let delta = stepper.next(direction: direction, duration: model.duration, at: .now)
        model.scrub(to: model.currentTime + delta)
        visibility?.interact()
        commitTask?.cancel()
        commitTask = Task {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            commit()
        }
    }

    private func commit() {
        commitTask?.cancel()
        commitTask = nil
        stepper.reset()
        model.endScrubbing()
    }
}

private struct ScrubTrack: View {
    let progress: Double
    let onFocusChange: (Bool) -> Void
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.3))
                Capsule().fill(.white)
                    .frame(width: proxy.size.width * progress)
                if isFocused {
                    Circle().fill(.white)
                        .frame(width: 28, height: 28)
                        .offset(x: proxy.size.width * progress - 14)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: isFocused ? 28 : 8)
        .padding(.vertical, 10)
        .animation(.easeOut(duration: 0.15), value: isFocused)
        .onChange(of: isFocused) { _, focused in onFocusChange(focused) }
    }
}
#endif

/// Scrub step that grows on quick repeated presses.
struct ScrubStepper {
    static let repeatWindow: Duration = .milliseconds(400)
    static let maxMultiplier: Double = 8

    private var lastPress: ContinuousClock.Instant?
    private var lastDirection: Double = 0
    private var multiplier: Double = 1

    static func baseStep(duration: TimeInterval) -> TimeInterval {
        min(max(duration / 200, 1), 10)
    }

    mutating func next(direction: Double, duration: TimeInterval, at now: ContinuousClock.Instant) -> TimeInterval {
        if let lastPress, lastDirection == direction, now - lastPress <= Self.repeatWindow {
            multiplier = min(multiplier * 2, Self.maxMultiplier)
        } else {
            multiplier = 1
        }
        lastPress = now
        lastDirection = direction
        return direction * Self.baseStep(duration: duration) * multiplier
    }

    mutating func reset() {
        self = ScrubStepper()
    }
}

public struct TimeLabel: View {
    public enum Kind: Sendable { case current, duration, remaining }

    @Environment(\.versaPlayer) private var model
    private let kind: Kind

    public init(_ kind: Kind) {
        self.kind = kind
    }

    public var body: some View {
        if let model {
            Text(text(for: model))
                .monospacedDigit()
        }
    }

    private func text(for model: VersaPlayerModel) -> String {
        if model.isLive { return kind == .current ? "LIVE" : "" }
        switch kind {
        case .current: return Self.format(model.currentTime)
        case .duration: return Self.format(model.duration)
        case .remaining: return "-" + Self.format(max(model.duration - model.currentTime, 0))
        }
    }

    nonisolated static func format(_ seconds: TimeInterval) -> String {
        let value = seconds.isFinite ? max(seconds, 0) : 0
        let pattern: Duration.TimeFormatStyle.Pattern = value >= 3600 ? .hourMinuteSecond : .minuteSecond
        return Duration.seconds(value.rounded(.down)).formatted(.time(pattern: pattern))
    }
}

public struct BufferingIndicator: View {
    @Environment(\.versaPlayer) private var model

    public init() {}

    public var body: some View {
        if let model, model.isBuffering || model.status == .loading {
            ProgressView()
                .accessibilityLabel("Loading")
        }
    }
}

/// Hidden when there's nothing to choose.
public struct TrackPicker: View {
    @Environment(\.versaPlayer) private var model
    private let kind: MediaTrack.Kind

    public init(_ kind: MediaTrack.Kind) {
        self.kind = kind
    }

    public var body: some View {
        if let model {
            let tracks = model.tracks(of: kind)
            if tracks.count >= (kind == .legible ? 1 : 2) {
                Menu {
                    Picker(title, selection: selection(model)) {
                        if kind == .legible {
                            Text("Off").tag(String?.none)
                        }
                        ForEach(tracks) { track in
                            Text(track.name).tag(Optional(track.id))
                        }
                    }
                } label: {
                    Image(systemName: kind == .legible ? "captions.bubble" : "speaker.wave.2")
                }
                .accessibilityLabel(title)
                #if os(macOS)
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                #endif
            }
        }
    }

    private var title: String {
        switch kind {
        case .audio: "Audio"
        case .legible: "Subtitles"
        case .video: "Video"
        }
    }

    private func selection(_ model: VersaPlayerModel) -> Binding<String?> {
        Binding(
            get: { model.selectedTracks[kind]?.id },
            set: { id in
                if let id, let track = model.tracks.first(where: { $0.id == id }) {
                    model.select(track)
                } else {
                    model.deselect(kind)
                }
            }
        )
    }
}

/// Hidden when PiP isn't possible.
public struct PiPButton: View {
    @Environment(\.versaPlayer) private var model

    public init() {}

    public var body: some View {
        if let model, model.isPictureInPicturePossible {
            Button {
                model.togglePictureInPicture()
            } label: {
                Image(systemName: model.isPictureInPictureActive ? "pip.exit" : "pip.enter")
            }
            .accessibilityLabel(model.isPictureInPictureActive ? "Exit Picture in Picture" : "Picture in Picture")
        }
    }
}

/// Visible when `.onFullscreenRequest` is set.
public struct FullscreenButton: View {
    @Environment(\.versaFullscreenRequest) private var request

    public init() {}

    public var body: some View {
        if let request {
            Button {
                request.toggle()
            } label: {
                Image(systemName: request.isFullscreen
                      ? "arrow.down.right.and.arrow.up.left"
                      : "arrow.up.left.and.arrow.down.right")
            }
            .accessibilityLabel(request.isFullscreen ? "Exit full screen" : "Full screen")
        }
    }
}

/// iOS and macOS only.
public struct AirPlayButton: View {
    public init() {}

    public var body: some View {
        #if os(iOS) || os(macOS)
        RoutePicker()
            .frame(width: 28, height: 28)
            .accessibilityLabel("AirPlay")
        #else
        EmptyView()
        #endif
    }
}

#if os(iOS)
private struct RoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.tintColor = .white
        view.prioritizesVideoDevices = true
        return view
    }
    func updateUIView(_ view: AVRoutePickerView, context: Context) {}
}
#elseif os(macOS)
private struct RoutePicker: NSViewRepresentable {
    func makeNSView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.isRoutePickerButtonBordered = false
        return view
    }
    func updateNSView(_ view: AVRoutePickerView, context: Context) {}
}
#endif
