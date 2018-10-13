//
//  VersaPlayer.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import UIKit
import CoreMedia
import AVFoundation
import AVKit

open class VersaPlayer: UIView, AVPictureInPictureControllerDelegate {

    public var extensions: [String: VersaPlayerExtension] = [:]
    public var player: VPlayer!
    public var renderingView: VPlayerRenderingView!
    
    public var playbackDelegate: VersaPlayerPlaybackDelegate? = nil
    
    private var nonFullscreenContainer: UIView!
    public var pipController: AVPictureInPictureController? = nil
    public var ready: Bool = false
    public var autoplay: Bool = true
    public var isPlaying: Bool = false
    public var isSeeking: Bool = false
    public var isFullscreenModeEnabled: Bool = false
    public var isPipModeEnabled: Bool = false
    
    public var isForwarding: Bool {
        return player.rate > 1
    }
    public var isRewinding: Bool {
        return player.rate < 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    public func addExtension(extension ext: VersaPlayerExtension, with name: String) {
        ext.player = self
        ext.prepare()
        extensions[name] = ext
    }
    
    public func getExtension(with name: String) -> VersaPlayerExtension? {
        return extensions[name]
    }
    
    public func prepare() {
        ready = true
        player = VPlayer()
        player.handler = self
        player.preparePlayerPlaybackDelegate()
        renderingView = VPlayerRenderingView(with: self)
        layout(view: renderingView, into: self)
    }
    
    public func layout(view: UIView, into: UIView) {
        into.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: into.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: into.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: into.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: into.bottomAnchor).isActive = true
    }
    
    public func setNativePip(enabled: Bool) {
        if enabled {
            pipController?.startPictureInPicture()
        }else {
            pipController?.stopPictureInPicture()
        }
    }
    
    public func setFullscreen(enabled: Bool) {
        if enabled {
            if let window = UIApplication.shared.keyWindow {
                nonFullscreenContainer = superview
                removeFromSuperview()
                layout(view: self, into: window)
                let value = UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }else {
            removeFromSuperview()
            layout(view: self, into: nonFullscreenContainer)
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
        
        isFullscreenModeEnabled = enabled
    }
    
    public func set(item: VPlayerItem?) {
        if !ready {
            prepare()
        }
        
        player.replaceCurrentItem(with: item)
        if autoplay && item?.error == nil {
            play()
        }
    }
    
    @IBAction public func play() {
        if playbackDelegate?.playbackShouldBegin(forPlayer: player) ?? true {
            player.play()
            isPlaying = true
        }
    }
    
    @IBAction public func pause() {
        player.pause()
        isPlaying = false
    }
    
    @IBAction public func togglePlayback() {
        if isPlaying {
            pause()
        }else {
            play()
        }
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //hide fallback
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //show fallback
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPipModeEnabled = false
        controls?.controlsCoordinator.isHidden = false
    }
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        controls?.controlsCoordinator.isHidden = true
        isPipModeEnabled = true
    }
    
}
