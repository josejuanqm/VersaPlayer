//
//  PlaybackErrorTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Foundation
import Testing
@testable import VersaPlayerCore

struct PlaybackErrorTests {
    @Test(arguments: [
        (-12937, PlaybackError.authenticationError),
        (-16840, .unauthorized),
        (-12660, .forbidden),
        (-12938, .notFound),
        (-12661, .unavailable),
        (-12645, .mediaFileError),
        (-12889, .mediaFileError),
        (-12318, .bandwidthExceeded),
        (-12642, .playlistUnchanged),
        (-12911, .decoderMalfunction),
        (-12913, .decoderTemporarilyUnavailable),
        (-1004, .wrongHostIP),
        (-1003, .wrongHostDNS),
        (-1000, .badURL),
        (-1202, .invalidRequest),
    ])
    func mapsUnderlyingCode(code: Int, expected: PlaybackError) {
        let underlying = NSError(domain: "CoreMediaErrorDomain", code: code)
        let error = NSError(domain: "AVFoundationErrorDomain", code: -11800, userInfo: [NSUnderlyingErrorKey: underlying])
        #expect(PlaybackError(error) == expected)
    }

    @Test func fallsBackToTopLevelCode() {
        let error = NSError(domain: NSURLErrorDomain, code: -1003)
        #expect(PlaybackError(error) == .wrongHostDNS)
    }

    @Test func unknownCodeKeepsDomainAndCode() {
        let error = NSError(domain: "Custom", code: 42, userInfo: [NSLocalizedDescriptionKey: "boom"])
        #expect(PlaybackError(error) == .underlying(domain: "Custom", code: 42, message: "boom"))
    }

    @Test func unknownUnderlyingFallsBackToTopLevel() {
        let underlying = NSError(domain: "X", code: 1)
        let error = NSError(domain: "Y", code: -1000, userInfo: [NSUnderlyingErrorKey: underlying])
        #expect(PlaybackError(error) == .badURL)
    }
}
