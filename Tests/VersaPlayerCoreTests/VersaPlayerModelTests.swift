//
//  VersaPlayerModelTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import Testing
@testable import VersaPlayerCore

@MainActor
@Suite(.serialized)
struct VersaPlayerModelTests {
    @Test func loadsAndBecomesReady() async throws {
        let model = VersaPlayerModel()
        let recorder = EventRecorder(model.events)
        model.load(VersaPlayerItem(url: try await TestClip.url()), autoplay: false)
        #expect(model.status == .loading)

        try await waitUntil { model.status == .ready }
        try await waitUntil { model.duration > 0 }
        #expect(abs(model.duration - 2) < 0.2)
        #expect(!model.isLive)
        #expect(!model.isPlaying)
        #expect(model.tracks(of: .audio).isEmpty)
        try await waitUntil { recorder.events.contains(.ready) }
        #expect(recorder.events.first.map { if case .itemLoaded = $0 { true } else { false } } == true)
    }

    @Test func playsToEndOnce() async throws {
        let model = VersaPlayerModel()
        let recorder = EventRecorder(model.events)
        model.load(VersaPlayerItem(url: try await TestClip.url()))
        try await waitUntil { recorder.events.contains(.playing) }
        #expect(model.isPlaying)
        try await waitUntil(timeout: .seconds(8)) { recorder.events.contains(.ended) }
        try await waitUntil { !model.isPlaying }
        try await Task.sleep(for: .milliseconds(200))
        #expect(recorder.events.filter { $0 == .ended }.count == 1)
    }

    @Test func gateBlocksPlayback() async throws {
        let model = VersaPlayerModel()
        var asked = 0
        model.shouldBeginPlayback = { _ in asked += 1; return false }
        model.load(VersaPlayerItem(url: try await TestClip.url()))
        try await waitUntil { model.status == .ready }
        try await Task.sleep(for: .milliseconds(300))
        #expect(asked == 1)
        #expect(!model.isPlaying)
    }

    @Test func seekUpdatesCurrentTime() async throws {
        let model = VersaPlayerModel()
        model.load(VersaPlayerItem(url: try await TestClip.url()), autoplay: false)
        try await waitUntil { model.status == .ready }
        let finished = await model.seek(to: 1.5)
        #expect(finished)
        #expect(abs(model.currentTime - 1.5) < 0.01)
        #expect(abs(model.player.currentTime().seconds - 1.5) < 0.11)
        await model.seek(to: 99)
        #expect(model.currentTime <= model.duration)
    }

    @Test func startTimeIsApplied() async throws {
        let model = VersaPlayerModel()
        model.load(VersaPlayerItem(url: try await TestClip.url(), startTime: 1), autoplay: false)
        try await waitUntil { model.status == .ready }
        try await waitUntil { abs(model.player.currentTime().seconds - 1) < 0.11 }
    }

    @Test func scrubbingPausesAndResumes() async throws {
        let model = VersaPlayerModel()
        model.load(VersaPlayerItem(url: try await TestClip.url()))
        try await waitUntil { model.isPlaying }
        model.beginScrubbing()
        #expect(model.isScrubbing)
        try await waitUntil { model.timeControlStatus == .paused }
        #expect(model.isPlaying)
        model.scrub(to: 0.5)
        model.scrub(to: 1.0)
        #expect(model.currentTime == 1.0)
        model.endScrubbing()
        #expect(!model.isScrubbing)
        try await waitUntil { model.timeControlStatus != .paused }
    }

    @Test func toggleWhileScrubbingChangesResume() async throws {
        let model = VersaPlayerModel()
        model.load(VersaPlayerItem(url: try await TestClip.url()))
        try await waitUntil { model.isPlaying }
        model.beginScrubbing()
        model.togglePlayback()
        #expect(!model.isPlaying)
        model.endScrubbing()
        try await Task.sleep(for: .milliseconds(300))
        #expect(model.timeControlStatus == .paused)
        #expect(!model.isPlaying)
    }

    @Test func unloadResets() async throws {
        let model = VersaPlayerModel()
        model.load(VersaPlayerItem(url: try await TestClip.url()), autoplay: false)
        try await waitUntil { model.status == .ready }
        model.unload()
        #expect(model.status == .idle)
        #expect(model.currentItem == nil)
        #expect(model.duration == 0)
        #expect(model.player.currentItem == nil)
    }

    @Test func badURLFails() async throws {
        let model = VersaPlayerModel()
        let missing = FileManager.default.temporaryDirectory.appendingPathComponent("does-not-exist.mov")
        model.load(VersaPlayerItem(url: missing))
        try await waitUntil {
            if case .failed = model.status { true } else { false }
        }
    }

    @Test func modelIsReleased() async throws {
        weak var weakModel: VersaPlayerModel?
        do {
            let model = VersaPlayerModel()
            weakModel = model
            model.load(VersaPlayerItem(url: try await TestClip.url()))
            try await waitUntil { model.isPlaying }
            model.pause()
        }
        try await waitUntil { weakModel == nil }
    }

    @Test func pluginLifecycle() {
        final class Probe: VersaPlayerPlugin {
            var attached = 0, detached = 0
            func attach(to model: VersaPlayerModel) { attached += 1 }
            func detach(from model: VersaPlayerModel) { detached += 1 }
        }
        let model = VersaPlayerModel()
        let probe = Probe()
        model.add(probe)
        model.add(probe)
        #expect(probe.attached == 1)
        #expect(model.plugin(of: Probe.self) === probe)
        model.remove(probe)
        #expect(probe.detached == 1)
        #expect(model.plugin(of: Probe.self) == nil)
    }
}

@MainActor
struct EventBroadcasterTests {
    @Test func fansOutToAllSubscribers() async throws {
        let broadcaster = EventBroadcaster<Int>()
        let a = EventRecorder(broadcaster.stream())
        let b = EventRecorder(broadcaster.stream())
        broadcaster.send(1)
        broadcaster.send(2)
        try await waitUntil { a.events == [1, 2] && b.events == [1, 2] }
    }
}
