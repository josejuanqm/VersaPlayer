//
//  MediaTrackTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Testing
@testable import VersaPlayerCore

@MainActor
struct MediaTrackTests {
    @Test func idIsStableAndDescriptive() {
        let first = MediaSelectionIndex.makeID(kind: .audio, languageTag: "en", name: "English", taken: [])
        let second = MediaSelectionIndex.makeID(kind: .audio, languageTag: "en", name: "English", taken: [])
        #expect(first == "audio-en-English")
        #expect(first == second)
    }

    @Test func missingLanguageUsesUnd() {
        #expect(MediaSelectionIndex.makeID(kind: .legible, languageTag: nil, name: "CC", taken: []) == "legible-und-CC")
    }

    @Test func duplicatesGetSuffix() {
        let taken: Set = ["audio-en-English", "audio-en-English-2"]
        #expect(MediaSelectionIndex.makeID(kind: .audio, languageTag: "en", name: "English", taken: taken) == "audio-en-English-3")
    }
}
