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

    /// VersaPlayer extension dictionary
    public var extensions: [String: VersaPlayerExtension] = [:]
    
    /// AVPlayer used in VersaPlayer implementation
    public var player: VPlayer!
    
    /// VPlayerRenderingView instance
    public var renderingView: VPlayerRenderingView!
    
    /// VersaPlayerPlaybackDelegate instance
    public var playbackDelegate: VersaPlayerPlaybackDelegate? = nil
    
    /// VersaPlayerDecryptionDelegate instance to be used only when a VPlayer item with isEncrypted = true is passed
    public var decryptionDelegate: VersaPlayerDecryptionDelegate? = nil
    
    /// VersaPlayer initial container
    private var nonFullscreenContainer: UIView!
    
    /// AVPictureInPictureController instance
    public var pipController: AVPictureInPictureController? = nil

    /// Whether player is prepared
    public var ready: Bool = false
    
    /// Whether it should autoplay when adding a VPlayerItem
    public var autoplay: Bool = true

    /// Whether Player is currently playing
    public var isPlaying: Bool = false
    
    /// Whether Player is seeking time
    public var isSeeking: Bool = false
    
    /// Whether Player is presented in Fullscreen
    public var isFullscreenModeEnabled: Bool = false
    
    /// Whether PIP Mode is enabled via pipController
    public var isPipModeEnabled: Bool = false
    
    /// Whether Player is Fast Forwarding
    public var isForwarding: Bool {
        return player.rate > 1
    }
    
    /// Whether Player is Rewinding
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
    
    /// Add a VersaPlayerExtension instance to the current player
    ///
    /// - Parameters:
    ///     - ext: The instance of the extension.
    ///     - name: The name of the extension.
    open func addExtension(extension ext: VersaPlayerExtension, with name: String) {
        ext.player = self
        ext.prepare()
        extensions[name] = ext
    }
    
    /// Retrieves the instance of the VersaPlayerExtension with the name given
    ///
    /// - Parameters:
    ///     - name: The name of the extension.
    open func getExtension(with name: String) -> VersaPlayerExtension? {
        return extensions[name]
    }
    
    /// Prepares the player to play
    open func prepare() {
        ready = true
        player = VPlayer()
        player.handler = self
        player.preparePlayerPlaybackDelegate()
        renderingView = VPlayerRenderingView(with: self)
        layout(view: renderingView, into: self)
    }
    
    /// Layout a view within another view stretching to edges
    ///
    /// - Parameters:
    ///     - view: The view to layout.
    ///     - into: The container view.
    open func layout(view: UIView, into: UIView) {
        into.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: into.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: into.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: into.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: into.bottomAnchor).isActive = true
    }
    
    /// Enables or disables PIP when available (when device is supported)
    ///
    /// - Parameters:
    ///     - enabled: Whether or not to enable
    open func setNativePip(enabled: Bool) {
        if enabled {
            pipController?.startPictureInPicture()
        }else {
            pipController?.stopPictureInPicture()
        }
    }
    
    /// Enables or disables fullscreen
    ///
    /// - Parameters:
    ///     - enabled: Whether or not to enable
    open func setFullscreen(enabled: Bool) {
        if enabled == isFullscreenModeEnabled {
            return
        }
        if enabled {
            if let window = UIApplication.shared.keyWindow {
                nonFullscreenContainer = superview
                removeFromSuperview()
                layout(view: self, into: window)
            }
        }else {
            removeFromSuperview()
            layout(view: self, into: nonFullscreenContainer)
        }
        
        isFullscreenModeEnabled = enabled
    }
    
    /// Sets the item to be played
    ///
    /// - Parameters:
    ///     - item: The VPlayerItem instance to add to player.
    open func set(item: VPlayerItem?) {
        if !ready {
            prepare()
        }
        
        player.replaceCurrentItem(with: item)
        if autoplay && item?.error == nil {
            play()
        }
    }
    
    /// Play
    @IBAction open func play() {
        if playbackDelegate?.playbackShouldBegin(player: player) ?? true {
            player.play()
            isPlaying = true
        }
    }
    
    /// Pause
    @IBAction open func pause() {
        player.pause()
        isPlaying = false
    }
    
    /// Toggle Playback
    @IBAction open func togglePlayback() {
        if isPlaying {
            pause()
        }else {
            play()
        }
    }
    
    open func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //hide fallback
    }
    
    open func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        //show fallback
    }
    
    open func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        isPipModeEnabled = false
        controls?.controlsCoordinator.isHidden = false
    }
    
    open func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        controls?.controlsCoordinator.isHidden = true
        isPipModeEnabled = true
    }
    
}
