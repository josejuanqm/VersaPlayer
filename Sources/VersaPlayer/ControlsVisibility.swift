//
//  ControlsVisibility.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Observation
import SwiftUI

/// Shows and auto-hides the controls overlay.
@MainActor
@Observable
public final class ControlsVisibility {
    public private(set) var isVisible = true

    public var autohideDelay: Duration? = .seconds(3) {
        didSet { reschedule() }
    }

    /// Set by the player: playing, not buffering, not scrubbing.
    public var canHide = false {
        didSet { if canHide != oldValue { reschedule() } }
    }

    @ObservationIgnored private var hideTask: Task<Void, Never>?
    @ObservationIgnored private let sleep: @Sendable (Duration) async throws -> Void

    public init() {
        self.sleep = { try await Task.sleep(for: $0) }
    }

    init(sleep: @escaping @Sendable (Duration) async throws -> Void) {
        self.sleep = sleep
    }

    public func show() {
        isVisible = true
        reschedule()
    }

    public func hide() {
        hideTask?.cancel()
        isVisible = false
    }

    public func toggle() {
        isVisible ? hide() : show()
    }

    /// Restarts the hide timer.
    public func interact() {
        show()
    }

    private func reschedule() {
        hideTask?.cancel()
        guard isVisible, canHide, let delay = autohideDelay else { return }
        let sleep = sleep
        hideTask = Task { [weak self] in
            do { try await sleep(delay) } catch { return }
            guard !Task.isCancelled, let self, self.canHide else { return }
            self.isVisible = false
        }
    }
}
