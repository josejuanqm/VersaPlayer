//
//  PlaybackError.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Foundation

public enum PlaybackError: Error, Sendable, Equatable {
    case notFound
    case unauthorized
    case authenticationError
    case forbidden
    case unavailable
    case mediaFileError
    case bandwidthExceeded
    case playlistUnchanged
    case decoderMalfunction
    case decoderTemporarilyUnavailable
    case wrongHostIP
    case wrongHostDNS
    case badURL
    case invalidRequest
    case contentKey(message: String)
    /// Any other error.
    case underlying(domain: String, code: Int, message: String)

    /// Maps an AVPlayer / AVPlayerItem error.
    public init(_ error: any Error) {
        let nsError = error as NSError
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
           let mapped = Self.known(code: underlying.code) {
            self = mapped
        } else if let mapped = Self.known(code: nsError.code) {
            self = mapped
        } else {
            self = .underlying(domain: nsError.domain, code: nsError.code, message: nsError.localizedDescription)
        }
    }

    static func known(code: Int) -> PlaybackError? {
        switch code {
        case -12937: .authenticationError
        case -16840: .unauthorized
        case -12660: .forbidden
        case -12938: .notFound
        case -12661: .unavailable
        case -12645, -12889: .mediaFileError
        case -12318: .bandwidthExceeded
        case -12642: .playlistUnchanged
        case -12911: .decoderMalfunction
        case -12913: .decoderTemporarilyUnavailable
        case -1004: .wrongHostIP
        case -1003: .wrongHostDNS
        case -1000: .badURL
        case -1202: .invalidRequest
        default: nil
        }
    }
}
