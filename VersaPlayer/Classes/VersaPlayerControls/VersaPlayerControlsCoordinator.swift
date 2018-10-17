//
//  VersaPlayerControlsCoordinator.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation

open class VersaPlayerControlsCoordinator: UIView, VersaPlayerGestureRecieverViewDelegate {

    /// VersaPlayer instance being used
    var player: VersaPlayer!
    
    /// VersaPlayerControls instance being used
    public var controls: VersaPlayerControls!
    
    /// VersaPlayerGestureRecieverView instance being used
    public var gestureReciever: VersaPlayerGestureRecieverView!
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let h = superview as? VersaPlayer {
            player = h
            if controls != nil {
                addSubview(controls)
            }
            if gestureReciever == nil {
                gestureReciever = VersaPlayerGestureRecieverView()
                gestureReciever.delegate = self
                addSubview(gestureReciever)
                sendSubview(toBack: gestureReciever)
            }
            layout()
        }
    }
    
    public func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        }
    }
    
    /// Notifies when pinch was recognized
    ///
    /// - Parameters:
    ///     - scale: CGFloat value
    public func didPinch(with scale: CGFloat) {
        if player.renderingView.renderingLayer.playerLayer.videoGravity == AVLayerVideoGravity.resizeAspect {
            player.renderingView.renderingLayer.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }else {
            player.renderingView.renderingLayer.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        }
    }
    
    /// Notifies when tap was recognized
    ///
    /// - Parameters:
    ///     - point: CGPoint at which tap was recognized
    public func didTap(at point: CGPoint) {
        if controls.behaviour.showingControls {
            controls.behaviour.hide()
        }else {
            controls.behaviour.show()
        }
    }
    
    /// Notifies when pan was recognized
    ///
    /// - Parameters:
    ///     - translation: translation of pan in CGPoint representation
    ///     - at: initial point recognized
    public func didPan(with translation: CGPoint, initially at: CGPoint) {
        let percentageTranslation: Double = Double(translation.x / gestureReciever.bounds.width)
        player.player.seek(to:
            CMTime.init(
                seconds: player.player.endTime().seconds * percentageTranslation,
                preferredTimescale: CMTimeScale(NSEC_PER_SEC)
            )
        )
    }

}
