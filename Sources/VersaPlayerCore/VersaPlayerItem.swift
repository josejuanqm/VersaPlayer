//
//  VersaPlayerItem.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation

/// What to play and how.
public struct VersaPlayerItem: Sendable {
    public var url: URL
    public var drm: DRMConfiguration?
    /// Seconds.
    public var startTime: TimeInterval?
    /// Caption appearance.
    public var captionStyle: CaptionStyle?
    public var quality: QualityPreference
    /// Seconds to buffer ahead.
    public var preferredForwardBufferDuration: TimeInterval?
    /// Display info.
    public var metadata: Metadata

    public init(
        url: URL,
        drm: DRMConfiguration? = nil,
        startTime: TimeInterval? = nil,
        captionStyle: CaptionStyle? = nil,
        quality: QualityPreference = .automatic,
        preferredForwardBufferDuration: TimeInterval? = nil,
        metadata: Metadata = Metadata()
    ) {
        self.url = url
        self.drm = drm
        self.startTime = startTime
        self.captionStyle = captionStyle
        self.quality = quality
        self.preferredForwardBufferDuration = preferredForwardBufferDuration
        self.metadata = metadata
    }

    public struct Metadata: Sendable, Equatable {
        public var title: String?
        public var subtitle: String?
        public var artworkURL: URL?

        public init(title: String? = nil, subtitle: String? = nil, artworkURL: URL? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.artworkURL = artworkURL
        }
    }
}

/// Caps for adaptive streams (HLS variants).
public struct QualityPreference: Sendable, Equatable {
    /// Bits per second. `nil` means no cap.
    public var peakBitRate: Double?
    /// `nil` means no cap.
    public var maximumResolution: CGSize?

    public init(peakBitRate: Double? = nil, maximumResolution: CGSize? = nil) {
        self.peakBitRate = peakBitRate
        self.maximumResolution = maximumResolution
    }

    public static let automatic = QualityPreference()

    func apply(to item: AVPlayerItem) {
        item.preferredPeakBitRate = peakBitRate ?? 0
        item.preferredMaximumResolution = maximumResolution ?? .zero
    }
}
