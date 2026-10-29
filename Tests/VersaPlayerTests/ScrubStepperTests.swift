//
//  ScrubStepperTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Testing
@testable import VersaPlayer

struct ScrubStepperTests {
    @Test func baseStepScalesWithDuration() {
        #expect(ScrubStepper.baseStep(duration: 60) == 1)
        #expect(ScrubStepper.baseStep(duration: 1000) == 5)
        #expect(ScrubStepper.baseStep(duration: 7200) == 10)
    }

    @Test func quickRepeatsAccelerate() {
        var stepper = ScrubStepper()
        let start = ContinuousClock.now
        let steps = (0..<5).map { stepper.next(direction: 1, duration: 1000, at: start + .milliseconds(100 * $0)) }
        #expect(steps == [5, 10, 20, 40, 40])
    }

    @Test func pauseOrReverseResets() {
        var stepper = ScrubStepper()
        let start = ContinuousClock.now
        _ = stepper.next(direction: 1, duration: 1000, at: start)
        #expect(stepper.next(direction: 1, duration: 1000, at: start + .milliseconds(100)) == 10)
        #expect(stepper.next(direction: -1, duration: 1000, at: start + .milliseconds(200)) == -5)
        #expect(stepper.next(direction: -1, duration: 1000, at: start + .seconds(2)) == -5)
    }
}
