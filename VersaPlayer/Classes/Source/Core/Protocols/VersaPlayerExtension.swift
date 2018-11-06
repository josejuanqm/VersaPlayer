//
//  VersaPlayerExtension.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/12/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation

open class VersaPlayerExtension: NSObject {
    
    /// VersaPlayer instance being used
    open var player: VersaPlayerView
    
    public init(with player: VersaPlayerView) {
        self.player = player
    }
    
    /// Notifies when player added the extension
    open func didAddExtension() {
        
    }
    
    /// Make preparations for the extension such as modifying the view
    open func prepare() {
        
    }
}
