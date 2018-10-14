//
//  VersaPlayerControlsExtension.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import CoreMedia

public extension VersaPlayer {
    
    private var versaPlayerControlsTag: Int { return 2000 }
    
    /// VersaPlayerControls instance being used to display controls
    public var controls: VersaPlayerControls? {
        get {
            return viewWithTag(versaPlayerControlsTag) as? VersaPlayerControls
        }
    }
    
    /// VersaPlayerControls instance to display controls in player, using VersaPlayerGestureRecieverView instance
    /// to handle gestures
    ///
    /// - Parameters:
    ///     - controls: VersaPlayerControls instance used to display controls
    ///     - gestureReciever: Optional gesture reciever view to be used to recieve gestures
    public func use(controls: VersaPlayerControls, with gestureReciever: VersaPlayerGestureRecieverView? = nil) {
        let coordinator = VersaPlayerControlsCoordinator()
        coordinator.player = self
        coordinator.controls = controls
        coordinator.gestureReciever = gestureReciever
        controls.controlsCoordinator = coordinator
        addSubview(coordinator)
        controls.tag = versaPlayerControlsTag
        bringSubview(toFront: controls)
    }
    
    /// Update controls to specified time
    ///
    /// - Parameters:
    ///     - time: Time to be updated to
    public func updateControls(toTime time: CMTime) {
        controls?.timeDidChange(toTime: time)
    }
    
}
