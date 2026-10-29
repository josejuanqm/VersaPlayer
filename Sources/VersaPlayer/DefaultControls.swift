//
//  DefaultControls.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import SwiftUI

public struct DefaultControls: View {
    public init() {}

    public var body: some View {
        #if os(tvOS)
        TVControls()
        #else
        StandardControls()
        #endif
    }
}

private struct StandardControls: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black.opacity(0.55), .clear, .clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack {
                HStack(spacing: 18) {
                    BufferingIndicator()
                    Spacer()
                    TrackPicker(.audio)
                    TrackPicker(.legible)
                    PiPButton()
                    AirPlayButton()
                    FullscreenButton()
                }
                .font(.title3)

                Spacer()

                HStack(spacing: 44) {
                    SkipButton(seconds: -10)
                        .font(.title)
                    PlayPauseButton()
                        .font(.system(size: 44))
                    SkipButton(seconds: 10)
                        .font(.title)
                }

                Spacer()

                HStack(spacing: 12) {
                    TimeLabel(.current)
                    Scrubber()
                    TimeLabel(.remaining)
                }
                .font(.caption)
            }
            .padding()
        }
        .foregroundStyle(.white)
        .tint(.white)
        .buttonStyle(.plain)
    }
}

#if os(tvOS)
/// Siri Remote: focus starts on the scrubber; swipe up for tracks and PiP.
private struct TVControls: View {
    @Environment(\.versaPlayer) private var model
    @Environment(ControlsVisibility.self) private var visibility: ControlsVisibility?
    @FocusState private var scrubberFocused: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black.opacity(0.5), .clear, .clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            if let model, !model.isPlaying, model.status == .ready {
                Image(systemName: "play.fill")
                    .font(.system(size: 80))
                    .allowsHitTesting(false)
            }
            BufferingIndicator()

            VStack {
                HStack(spacing: 24) {
                    Spacer()
                    TrackPicker(.audio)
                    TrackPicker(.legible)
                    PiPButton()
                }
                .focusSection()

                Spacer()

                HStack(spacing: 24) {
                    TimeLabel(.current)
                    Scrubber()
                        .focused($scrubberFocused)
                    TimeLabel(.remaining)
                }
                .font(.callout)
                .focusSection()
            }
            .padding(60)
        }
        .foregroundStyle(.white)
        .controlsTakeFocus()
        .defaultFocus($scrubberFocused, true)
        .onChange(of: visibility?.isVisible) { _, visible in
            guard visible == true else { return }
            Task { scrubberFocused = true }
        }
    }
}
#endif
