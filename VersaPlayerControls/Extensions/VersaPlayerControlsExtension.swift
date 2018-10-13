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
    public var controls: VersaPlayerControls? {
        get {
            return viewWithTag(versaPlayerControlsTag) as? VersaPlayerControls
        }
    }
    
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
    
    public func updateControls(toTime time: CMTime) {
        controls?.timeDidChange(toTime: time)
    }
    
}
