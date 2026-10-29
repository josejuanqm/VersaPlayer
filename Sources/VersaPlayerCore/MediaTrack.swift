//
//  MediaTrack.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation

public struct MediaTrack: Identifiable, Hashable, Sendable {
    public enum Kind: String, Sendable, CaseIterable {
        case audio
        case legible
        case video

        var characteristic: AVMediaCharacteristic {
            switch self {
            case .audio: .audible
            case .legible: .legible
            case .video: .visual
            }
        }
    }

    public let id: String
    public let kind: Kind
    public let name: String
    /// BCP 47 tag.
    public let languageTag: String?
}

/// AVFoundation objects behind each `MediaTrack`.
@MainActor
struct MediaSelectionIndex {
    private(set) var tracks: [MediaTrack] = []
    private var options: [MediaTrack.ID: AVMediaSelectionOption] = [:]
    private var groups: [MediaTrack.Kind: AVMediaSelectionGroup] = [:]

    static func load(from asset: AVAsset) async -> MediaSelectionIndex {
        var index = MediaSelectionIndex()
        guard let characteristics = try? await asset.load(.availableMediaCharacteristicsWithMediaSelectionOptions) else {
            return index
        }
        for kind in MediaTrack.Kind.allCases where characteristics.contains(kind.characteristic) {
            guard let group = try? await asset.loadMediaSelectionGroup(for: kind.characteristic) else { continue }
            index.groups[kind] = group
            for option in group.options {
                let track = MediaTrack(
                    id: Self.makeID(kind: kind, languageTag: option.extendedLanguageTag, name: option.displayName, taken: Set(index.options.keys)),
                    kind: kind,
                    name: option.displayName,
                    languageTag: option.extendedLanguageTag
                )
                index.tracks.append(track)
                index.options[track.id] = option
            }
        }
        return index
    }

    /// Same tracks get the same ID across items.
    nonisolated static func makeID(kind: MediaTrack.Kind, languageTag: String?, name: String, taken: Set<String>) -> String {
        let base = "\(kind.rawValue)-\(languageTag ?? "und")-\(name)"
        var id = base
        var suffix = 2
        while taken.contains(id) {
            id = "\(base)-\(suffix)"
            suffix += 1
        }
        return id
    }

    func group(for kind: MediaTrack.Kind) -> AVMediaSelectionGroup? {
        groups[kind]
    }

    func option(for track: MediaTrack) -> AVMediaSelectionOption? {
        options[track.id]
    }

    func allowsEmptySelection(_ kind: MediaTrack.Kind) -> Bool {
        groups[kind]?.allowsEmptySelection ?? false
    }

    /// Selected track per kind.
    func selection(in item: AVPlayerItem) -> [MediaTrack.Kind: MediaTrack] {
        var result: [MediaTrack.Kind: MediaTrack] = [:]
        for (kind, group) in groups {
            guard let option = item.currentMediaSelection.selectedMediaOption(in: group),
                  let track = tracks.first(where: { options[$0.id] == option }) else { continue }
            result[kind] = track
        }
        return result
    }
}
