//
//  DRMTests.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Foundation
import Testing
@testable import VersaPlayerCore

private final class FakeRequest: KeyRequest, @unchecked Sendable {
    let keyURI: String?
    var spcInputs: (certificate: Data, contentID: Data)?
    var ckc: Data?
    var error: (any Error)?

    init(keyURI: String?) { self.keyURI = keyURI }

    func makeSPC(certificate: Data, contentID: Data) async throws -> Data {
        spcInputs = (certificate, contentID)
        return Data("spc".utf8)
    }
    func respond(ckc: Data) { self.ckc = ckc }
    func fail(_ error: any Error) { self.error = error }
}

private struct FakeProvider: ContentKeyProvider {
    var failCertificate = false
    func certificate() async throws -> Data {
        if failCertificate { throw PlaybackError.contentKey(message: "no cert") }
        return Data("cert".utf8)
    }
    func contentKey(spc: Data, contentID: String) async throws -> Data {
        Data("ckc:\(contentID):\(String(decoding: spc, as: UTF8.self))".utf8)
    }
}

struct DRMTests {
    @Test func successfulExchange() async {
        let request = FakeRequest(keyURI: "skd://asset-123")
        await ContentKeyHandling.handle(request, provider: FakeProvider())
        #expect(request.error == nil)
        #expect(request.spcInputs?.certificate == Data("cert".utf8))
        #expect(request.spcInputs?.contentID == Data("asset-123".utf8))
        #expect(request.ckc == Data("ckc:asset-123:spc".utf8))
    }

    @Test func rejectsNonSkdURI() async {
        let request = FakeRequest(keyURI: "https://example.com/key")
        await ContentKeyHandling.handle(request, provider: FakeProvider())
        #expect(request.ckc == nil)
        #expect(request.error != nil)
    }

    @Test func providerFailureFailsRequest() async {
        let request = FakeRequest(keyURI: "skd://x")
        await ContentKeyHandling.handle(request, provider: FakeProvider(failCertificate: true))
        #expect(request.ckc == nil)
        #expect(request.error as? PlaybackError == .contentKey(message: "no cert"))
    }

    @Test func httpProviderContentID() {
        let url = URL(string: "https://example.com")!
        let derived = FairPlayHTTPProvider(certificateURL: url, licenseURL: url)
        #expect(derived.contentID(forKeyURI: "skd://abc") == "abc")
        let fixed = FairPlayHTTPProvider(certificateURL: url, licenseURL: url, contentID: "fixed")
        #expect(fixed.contentID(forKeyURI: "skd://abc") == "fixed")
    }
}
