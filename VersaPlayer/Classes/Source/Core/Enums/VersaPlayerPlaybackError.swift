//
//  VersaPlayerPlaybackError.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/23/18.
//

import Foundation

public enum VersaPlayerPlaybackError {
    case unknown
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
}
