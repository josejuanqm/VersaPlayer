//
//  Environment.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import SwiftUI

/// Lets the fullscreen button ask the app to toggle fullscreen.
public struct FullscreenRequest: Sendable {
    public var isFullscreen: Bool
    public var toggle: @MainActor @Sendable () -> Void
}

extension EnvironmentValues {
    /// Model of the enclosing `VersaVideoPlayer`.
    @Entry public var versaPlayer: VersaPlayerModel? = nil
    @Entry var versaFullscreenRequest: FullscreenRequest? = nil
    @Entry var versaVideoGravity: AVLayerVideoGravity = .resizeAspect
    @Entry var versaAutohideDelay: Duration? = .seconds(3)
    @Entry var versaDoubleTapTogglesGravity: Bool = true
}

extension View {
    /// How video fills the player. Default `.resizeAspect`.
    public func videoGravity(_ gravity: AVLayerVideoGravity) -> some View {
        environment(\.versaVideoGravity, gravity)
    }

    /// Controls hide after this delay while playing. `nil` keeps them visible.
    public func controlsAutohide(after delay: Duration?) -> some View {
        environment(\.versaAutohideDelay, delay)
    }

    /// Shows the fullscreen button.
    public func onFullscreenRequest(isFullscreen: Bool, perform: @escaping @MainActor @Sendable () -> Void) -> some View {
        environment(\.versaFullscreenRequest, FullscreenRequest(isFullscreen: isFullscreen, toggle: perform))
    }

    /// Double tap toggles aspect fit / fill.
    public func doubleTapTogglesGravity(_ enabled: Bool) -> some View {
        environment(\.versaDoubleTapTogglesGravity, enabled)
    }

    /// tvOS: moves focus from the video into the controls while they're visible.
    public func controlsTakeFocus(_ enabled: Bool = true) -> some View {
        preference(key: ControlsTakeFocusKey.self, value: enabled)
    }
}

struct ControlsTakeFocusKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
