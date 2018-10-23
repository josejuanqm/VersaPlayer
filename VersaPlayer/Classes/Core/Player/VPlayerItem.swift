//
//  VPlayerItem.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import AVFoundation

open class VPlayerItem: AVPlayerItem {
    
    /// whether content passed through the asset is encrypted and should be decrypted
    public var isEncrypted: Bool = false
    
}
