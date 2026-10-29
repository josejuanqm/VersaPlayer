//
//  PlaybackEvent.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import Foundation

/// One-off playback events. Continuous state lives on `VersaPlayerModel`.
public enum PlaybackEvent: Sendable, Equatable {
    case itemLoaded(URL)
    case ready
    case playing
    case paused
    case bufferingStarted
    case bufferingEnded
    case ended
    /// Seek or stream discontinuity.
    case timeJumped
    case failed(PlaybackError)
}

/// Fans events out to every stream it hands out.
@MainActor
final class EventBroadcaster<Event: Sendable> {
    private var continuations: [UUID: AsyncStream<Event>.Continuation] = [:]

    func stream() -> AsyncStream<Event> {
        let (stream, continuation) = AsyncStream<Event>.makeStream(bufferingPolicy: .bufferingNewest(64))
        let id = UUID()
        continuations[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { @MainActor in self?.continuations[id] = nil }
        }
        return stream
    }

    func send(_ event: Event) {
        for continuation in continuations.values {
            continuation.yield(event)
        }
    }

    func finish() {
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations = [:]
    }
}
