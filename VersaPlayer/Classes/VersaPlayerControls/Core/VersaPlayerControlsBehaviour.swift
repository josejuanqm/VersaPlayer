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
    
    /// VersaPlayerControls instance being controlled
    public var controls: VersaPlayerControls
    
    /// Whether controls are bieng displayed
    public var showingControls: Bool = true
    
    /// Whether controls should be hidden when showingControls is true
    public var shouldHideControls: Bool = true
    
    /// Whether controls should be shown when showingControls is false
    public var shouldShowControls: Bool = true
    
    /// Elapsed time between controls being shown and current time
    public var elapsedTime: TimeInterval = 0
    
    /// Last time when controls were shown
    public var activationTime: TimeInterval = 0
    
    /// At which TimeInterval controls hide automatically
    public var deactivationTimeInterval: TimeInterval = 3
    
    /// Custom deactivation block
    public var deactivationBlock: ((VersaPlayerControls) -> Void)? = nil
    
    /// Custom activation block
    public var activationBlock: ((VersaPlayerControls) -> Void)? = nil
    
    /// Constructor
    ///
    /// - Parameters:
    ///     - controls: VersaPlayerControls to be controlled.
    public init(with controls: VersaPlayerControls) {
        self.controls = controls
    }
    
    /// Update ui based on time
    ///
    /// - Parameters:
    ///     - time: TimeInterval to check whether to update controls.
    public func update(with time: TimeInterval) {
        elapsedTime = time
        if showingControls && shouldHideControls && !controls.handler.player.isBuffering && !controls.handler.isSeeking {
            let timediff = elapsedTime - activationTime
            if timediff >= deactivationTimeInterval {
                hide()
            }
        }
    }
    
    /// Default activation block
    public func defaultActivationBlock() {
        controls.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.controls.alpha = 1
        })
    }
    
    /// Default deactivation block
    public func defaultDeactivationBlock() {
        UIView.animate(withDuration: 0.3, animations: {
            self.controls.alpha = 0
        }, completion: {
            if $0 {
                self.controls.isHidden = true
            }
        })
    }
    
    /// Hide the controls
    public func hide() {
        if deactivationBlock != nil {
            deactivationBlock!(controls)
        }else {
            defaultDeactivationBlock()
        }
        showingControls = false
    }
    
    /// Show the controls
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
