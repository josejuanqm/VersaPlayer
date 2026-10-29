//
//  NowPlayingTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import MediaPlayer
import Testing
@testable import VersaPlayerCore

@MainActor
@Suite(.serialized)
struct NowPlayingTests {
    @Test func publishesItemInfo() async throws {
        let model = VersaPlayerModel()
        let plugin = NowPlayingPlugin()
        model.add(plugin)
        let metadata = VersaPlayerItem.Metadata(title: "Clip", subtitle: "Tests")
        model.load(VersaPlayerItem(url: try await TestClip.url(), metadata: metadata), autoplay: false)

        let center = MPNowPlayingInfoCenter.default()
        try await waitUntil { center.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] != nil }
        let info = try #require(center.nowPlayingInfo)
        #expect(info[MPMediaItemPropertyTitle] as? String == "Clip")
        #expect(info[MPMediaItemPropertyArtist] as? String == "Tests")
        #expect((info[MPNowPlayingInfoPropertyPlaybackRate] as? NSNumber)?.doubleValue == 0)

        model.remove(plugin)
        #expect(center.nowPlayingInfo == nil)
    }

    @Test func clearsInfoOnUnload() async throws {
        let model = VersaPlayerModel()
        let plugin = NowPlayingPlugin()
        model.add(plugin)
        model.load(VersaPlayerItem(url: try await TestClip.url()), autoplay: false)
        try await waitUntil { MPNowPlayingInfoCenter.default().nowPlayingInfo != nil }
        model.unload()
        try await waitUntil { MPNowPlayingInfoCenter.default().nowPlayingInfo == nil }
        model.remove(plugin)
    }
}
