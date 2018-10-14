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
    public var player: VersaPlayer
    
    public init(with player: VersaPlayer) {
        self.player = player
    }
    
    /// Notifies when player added the extension
    public func didAddExtension() {
        
    }
    
    /// Make preparations for the extension such as modifying the view
    public func prepare() {
        
    }
}
