//
//  ControlsTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Testing
@testable import VersaPlayer

@MainActor
struct ControlsVisibilityTests {
    @Test func hidesAfterDelayWhenAllowed() async throws {
        let visibility = ControlsVisibility(sleep: { _ in })
        #expect(visibility.isVisible)
        visibility.canHide = true
        try await waitUntil { !visibility.isVisible }
    }

    @Test func staysVisibleWhenNotAllowed() async throws {
        let visibility = ControlsVisibility(sleep: { _ in })
        visibility.show()
        try await Task.sleep(for: .milliseconds(50))
        #expect(visibility.isVisible)
    }

    @Test func staysVisibleWhenAutohideDisabled() async throws {
        let visibility = ControlsVisibility(sleep: { _ in })
        visibility.autohideDelay = nil
        visibility.canHide = true
        try await Task.sleep(for: .milliseconds(50))
        #expect(visibility.isVisible)
    }

    @Test func blockedHideIsCancelled() async throws {
        let visibility = ControlsVisibility(sleep: { _ in try await Task.sleep(for: .milliseconds(100)) })
        visibility.canHide = true
        visibility.canHide = false
        try await Task.sleep(for: .milliseconds(200))
        #expect(visibility.isVisible)
    }

    @Test func toggleAndInteract() {
        let visibility = ControlsVisibility(sleep: { _ in try await Task.sleep(for: .seconds(60)) })
        visibility.toggle()
        #expect(!visibility.isVisible)
        visibility.interact()
        #expect(visibility.isVisible)
    }
}

struct FormattingTests {
    @Test(arguments: [
        (0.0, "0:00"),
        (5.9, "0:05"),
        (65, "1:05"),
        (3599, "59:59"),
        (3600, "1:00:00"),
        (90061, "25:01:01"),
        (-3, "0:00"),
        (.nan, "0:00"),
        (.infinity, "0:00"),
    ])
    func timeLabel(seconds: Double, expected: String) {
        #expect(TimeLabel.format(seconds) == expected)
    }

    @Test func skipSymbols() {
        #expect(SkipButton.symbol(for: -10) == "gobackward.10")
        #expect(SkipButton.symbol(for: 30) == "goforward.30")
        #expect(SkipButton.symbol(for: 7) == "goforward")
    }
}

@MainActor
func waitUntil(timeout: Duration = .seconds(5), _ condition: () -> Bool) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now + timeout
    while !condition() {
        if clock.now > deadline { throw CancellationError() }
        try await Task.sleep(for: .milliseconds(10))
    }
}
