//
//  DRM.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation

/// Supplies FairPlay Streaming keys.
public protocol ContentKeyProvider: Sendable {
    func certificate() async throws -> Data
    func contentKey(spc: Data, contentID: String) async throws -> Data
    /// Default: the key URI without `skd://`.
    func contentID(forKeyURI uri: String) -> String
}

extension ContentKeyProvider {
    public func contentID(forKeyURI uri: String) -> String {
        uri.hasPrefix("skd://") ? String(uri.dropFirst("skd://".count)) : uri
    }
}

public struct DRMConfiguration: Sendable {
    public var provider: any ContentKeyProvider
    public init(provider: any ContentKeyProvider) {
        self.provider = provider
    }
}

/// Fetches the certificate (cached) and posts the SPC to `licenseURL` for the CKC.
public final class FairPlayHTTPProvider: ContentKeyProvider {
    public let certificateURL: URL
    public let licenseURL: URL
    private let fixedContentID: String?
    private let session: URLSession
    private let cache = CertificateCache()

    /// `contentID`: fixed ID, or `nil` to derive it from the key URI.
    public init(certificateURL: URL, licenseURL: URL, contentID: String? = nil, session: URLSession = .shared) {
        self.certificateURL = certificateURL
        self.licenseURL = licenseURL
        self.fixedContentID = contentID
        self.session = session
    }

    public func certificate() async throws -> Data {
        if let cached = await cache.data { return cached }
        let (data, response) = try await session.data(from: certificateURL)
        try Self.check(response)
        await cache.store(data)
        return data
    }

    public func contentKey(spc: Data, contentID: String) async throws -> Data {
        var request = URLRequest(url: licenseURL)
        request.httpMethod = "POST"
        request.httpBody = spc
        let (data, response) = try await session.data(for: request)
        try Self.check(response)
        return data
    }

    public func contentID(forKeyURI uri: String) -> String {
        fixedContentID ?? (uri.hasPrefix("skd://") ? String(uri.dropFirst("skd://".count)) : uri)
    }

    private static func check(_ response: URLResponse) throws {
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw PlaybackError.contentKey(message: "HTTP \(http.statusCode) from \(http.url?.absoluteString ?? "license server")")
        }
    }

    private actor CertificateCache {
        var data: Data?
        func store(_ data: Data) { self.data = data }
    }
}

/// The parts of `AVContentKeyRequest` the handler uses.
protocol KeyRequest: Sendable {
    var keyURI: String? { get }
    func makeSPC(certificate: Data, contentID: Data) async throws -> Data
    func respond(ckc: Data)
    func fail(_ error: any Error)
}

enum ContentKeyHandling {
    /// Runs the FairPlay exchange for one request.
    static func handle(_ request: some KeyRequest, provider: any ContentKeyProvider) async {
        guard let uri = request.keyURI, uri.hasPrefix("skd://") else {
            request.fail(PlaybackError.contentKey(message: "Unsupported key URI: \(request.keyURI ?? "nil")"))
            return
        }
        do {
            let contentID = provider.contentID(forKeyURI: uri)
            let certificate = try await provider.certificate()
            let spc = try await request.makeSPC(certificate: certificate, contentID: Data(contentID.utf8))
            let ckc = try await provider.contentKey(spc: spc, contentID: contentID)
            request.respond(ckc: ckc)
        } catch {
            request.fail(error)
        }
    }
}

/// `AVContentKeyRequest` wrapper.
struct AVKeyRequest: KeyRequest, @unchecked Sendable {
    let request: AVContentKeyRequest

    var keyURI: String? { request.identifier as? String }

    func makeSPC(certificate: Data, contentID: Data) async throws -> Data {
        try await request.makeStreamingContentKeyRequestData(forApp: certificate, contentIdentifier: contentID, options: nil)
    }

    func respond(ckc: Data) {
        request.processContentKeyResponse(AVContentKeyResponse(fairPlayStreamingKeyResponseData: ckc))
    }

    func fail(_ error: any Error) {
        request.processContentKeyResponseError(error)
    }
}

final class ContentKeySessionHandler: NSObject, AVContentKeySessionDelegate, @unchecked Sendable {
    private let provider: any ContentKeyProvider
    private let session: AVContentKeySession
    private let queue = DispatchQueue(label: "versaplayer.contentkey")
    var onError: (@Sendable (any Error) -> Void)?

    init(provider: any ContentKeyProvider, asset: AVURLAsset) {
        self.provider = provider
        self.session = AVContentKeySession(keySystem: .fairPlayStreaming)
        super.init()
        session.setDelegate(self, queue: queue)
        session.addContentKeyRecipient(asset)
    }

    func invalidate() {
        session.expire()
    }

    func contentKeySession(_ session: AVContentKeySession, didProvide keyRequest: AVContentKeyRequest) {
        process(AVKeyRequest(request: keyRequest))
    }

    func contentKeySession(_ session: AVContentKeySession, didProvideRenewingContentKeyRequest keyRequest: AVContentKeyRequest) {
        process(AVKeyRequest(request: keyRequest))
    }

    func contentKeySession(_ session: AVContentKeySession, contentKeyRequest keyRequest: AVContentKeyRequest, didFailWithError err: any Error) {
        onError?(err)
    }

    private func process(_ request: AVKeyRequest) {
        let provider = provider
        let onError = onError
        Task {
            await ContentKeyHandling.handle(FailureReporting(base: request, onError: onError), provider: provider)
        }
    }

    private struct FailureReporting: KeyRequest {
        let base: AVKeyRequest
        let onError: (@Sendable (any Error) -> Void)?
        var keyURI: String? { base.keyURI }
        func makeSPC(certificate: Data, contentID: Data) async throws -> Data {
            try await base.makeSPC(certificate: certificate, contentID: contentID)
        }
        func respond(ckc: Data) { base.respond(ckc: ckc) }
        func fail(_ error: any Error) {
            base.fail(error)
            onError?(error)
        }
    }
}
