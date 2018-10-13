//
//  VersaPlayerControlsBehaviour.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import UIKit

open class VersaPlayerControlsBehaviour {
    
    public var controls: VersaPlayerControls
    public var showingControls: Bool = true
    public var shouldHideControls: Bool = true
    public var shouldShowControls: Bool = true
    public var elapsedTime: TimeInterval = 0
    public var activationTime: TimeInterval = 0
    public var deactivationTimeInterval: TimeInterval = 3
    public var deactivationBlock: ((VersaPlayerControls) -> Void)? = nil
    public var activationBlock: ((VersaPlayerControls) -> Void)? = nil
    
    public init(with controls: VersaPlayerControls) {
        self.controls = controls
    }
    
    public func update(with time: TimeInterval) {
        elapsedTime = time
        if showingControls && shouldHideControls && !controls.handler.player.isBuffering && !controls.handler.isSeeking {
            let timediff = elapsedTime - activationTime
            if timediff >= deactivationTimeInterval {
                hide()
            }
        }
    }
    
    public func defaultActivationBlock() {
        controls.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.controls.alpha = 1
        })
    }
    
    public func defaultDeactivationBlock() {
        UIView.animate(withDuration: 0.3, animations: {
            self.controls.alpha = 0
        }, completion: {
            if $0 {
                self.controls.isHidden = true
            }
        })
    }
    
    public func hide() {
        if deactivationBlock != nil {
            deactivationBlock!(controls)
        }else {
            defaultDeactivationBlock()
        }
        showingControls = false
    }
    
    public func show() {
        if !shouldShowControls {
            return
        }
        activationTime = elapsedTime
        if activationBlock != nil {
            activationBlock!(controls)
        }else {
            defaultActivationBlock()
        }
        showingControls = true
    }
    
}
