//
//  VPlayerItem.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import AVFoundation

open class VersaPlayerItem: AVPlayerItem {
    
    /// whether content passed through the asset is encrypted and should be decrypted
    public var isEncrypted: Bool = false
    
    public var audioTracks: [VersaPlayerMediaTrack] {
        return tracks(for: .audible)
    }
    
    public var videoTracks: [VersaPlayerMediaTrack] {
        return tracks(for: .visual)
    }
    
    public var captionTracks: [VersaPlayerMediaTrack] {
        return tracks(for: .legible)
    }

    deinit {
     
    }

    private func tracks(for characteristic: AVMediaCharacteristic) -> [VersaPlayerMediaTrack] {
        guard let group = asset.mediaSelectionGroup(forMediaCharacteristic: characteristic) else {
            return []
        }
        let options = group.options
        let tracks = options.map { (option) -> VersaPlayerMediaTrack in
            let title = option.displayName
            let language = option.extendedLanguageTag ?? "none"
            return VersaPlayerMediaTrack(option: option, group: group, name: title, language: language)
        }
        return tracks
    }
    
}
