//
//  VersaVideoPlayer.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import SwiftUI

/// Video with an auto-hiding controls overlay.
public struct VersaVideoPlayer<Controls: View>: View {
    private let model: VersaPlayerModel
    private let controls: Controls

    @State private var visibility = ControlsVisibility()
    @State private var gravityOverride: AVLayerVideoGravity?
    @State private var controlsTakeFocus = false
    @Environment(\.versaVideoGravity) private var gravity
    @Environment(\.versaAutohideDelay) private var autohideDelay
    @Environment(\.versaDoubleTapTogglesGravity) private var doubleTapTogglesGravity

    public init(model: VersaPlayerModel, @ViewBuilder controls: () -> Controls) {
        self.model = model
        self.controls = controls()
    }

    public var body: some View {
        layers
            #if os(tvOS)
            .modifier(TVPlayerCommands(model: model, visibility: visibility))
            #else
            .contentShape(Rectangle())
            .modifier(PlayerInput(model: model, visibility: visibility, onDoubleTap: doubleTapAction))
            #endif
            .environment(\.versaPlayer, model)
            .environment(visibility)
            .onChange(of: canHide, initial: true) { _, newValue in
                visibility.canHide = newValue
            }
            .onChange(of: autohideDelay, initial: true) { _, newValue in
                visibility.autohideDelay = newValue
            }
    }

    private var layers: some View {
        ZStack {
            surface
            controls
                .opacity(visibility.isVisible ? 1 : 0)
                .allowsHitTesting(visibility.isVisible)
                #if os(tvOS)
                .disabled(!visibility.isVisible)
                .focusSection()
                .onPreferenceChange(ControlsTakeFocusKey.self) { controlsTakeFocus = $0 }
                #endif
                .animation(.easeInOut(duration: 0.25), value: visibility.isVisible)
        }
    }

    private var surface: some View {
        ZStack {
            Color.black
            VideoSurface(model: model, gravity: gravityOverride ?? gravity)
        }
        #if os(tvOS)
        .modifier(TVSurfaceInput(
            model: model,
            visibility: visibility,
            isFocusable: !(visibility.isVisible && controlsTakeFocus)
        ))
        #endif
    }

    private var doubleTapAction: (() -> Void)? {
        guard doubleTapTogglesGravity else { return nil }
        return { toggleGravity() }
    }

    private var canHide: Bool {
        model.isPlaying && !model.isBuffering && !model.isScrubbing
    }

    private func toggleGravity() {
        let current = gravityOverride ?? gravity
        gravityOverride = current == .resizeAspect ? .resizeAspectFill : .resizeAspect
    }
}

extension VersaVideoPlayer where Controls == DefaultControls {
    public init(model: VersaPlayerModel) {
        self.init(model: model) { DefaultControls() }
    }
}

#if os(tvOS)
/// Siri Remote input on the video while it has focus.
private struct TVSurfaceInput: ViewModifier {
    let model: VersaPlayerModel
    let visibility: ControlsVisibility
    let isFocusable: Bool
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focusable(isFocusable)
            .focused($isFocused)
            .focusEffectDisabled()
            .onMoveCommand { direction in
                switch direction {
                case .left: model.skip(by: -10)
                case .right: model.skip(by: 10)
                default: break
                }
                visibility.interact()
            }
            .onTapGesture {
                if visibility.isVisible { model.togglePlayback() }
                visibility.interact()
            }
            .onChange(of: isFocusable) { _, focusable in
                guard focusable else { return }
                Task { isFocused = true }
            }
    }
}

/// Remote commands that work wherever focus is inside the player.
private struct TVPlayerCommands: ViewModifier {
    let model: VersaPlayerModel
    let visibility: ControlsVisibility

    func body(content: Content) -> some View {
        content
            .onPlayPauseCommand {
                model.togglePlayback()
                visibility.interact()
            }
            .onExitCommand(perform: visibility.isVisible ? { visibility.hide() } : nil)
    }
}
#else
private struct PlayerInput: ViewModifier {
    let model: VersaPlayerModel
    let visibility: ControlsVisibility
    let onDoubleTap: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .modifier(DoubleTap(action: onDoubleTap))
            .onTapGesture { visibility.toggle() }
            #if os(macOS)
            .onContinuousHover { phase in
                if case .active = phase { visibility.interact() }
            }
            .focusable()
            .focusEffectDisabled()
            .onKeyPress(.space) {
                model.togglePlayback()
                visibility.interact()
                return .handled
            }
            .onKeyPress(.leftArrow) {
                model.skip(by: -10)
                visibility.interact()
                return .handled
            }
            .onKeyPress(.rightArrow) {
                model.skip(by: 10)
                visibility.interact()
                return .handled
            }
            #endif
    }
}

#endif

private struct DoubleTap: ViewModifier {
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        if let action {
            content.onTapGesture(count: 2, perform: action)
        } else {
            content
        }
    }
}
