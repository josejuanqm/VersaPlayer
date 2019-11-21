//
//  VersaPlayerView.swift
//  VersaPlayerView Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import CoreMedia
import AVFoundation
import AVKit


#if os(macOS)
public typealias View = NSView
#else
public typealias View = UIView
#endif

#if os(iOS)
public typealias PIPProtocol = AVPictureInPictureControllerDelegate
#else
public protocol PIPProtocol {}
#endif

open class VersaPlayerView: View, PIPProtocol {
    
    deinit {
        player.replaceCurrentItem(with: nil)
    }

    /// VersaPlayer extension dictionary
    public var extensions: [String: VersaPlayerExtension] = [:]
    
    /// AVPlayer used in VersaPlayer implementation
    public var player: VersaPlayer!
    
    /// VersaPlayerControls instance being used to display controls
    public var controls: VersaPlayerControls? = nil
    
    /// VersaPlayerRenderingView instance
    public var renderingView: VersaPlayerRenderingView!
    
    /// VersaPlayerPlaybackDelegate instance
    public weak var playbackDelegate: VersaPlayerPlaybackDelegate? = nil
    
    /// VersaPlayerDecryptionDelegate instance to be used only when a VPlayer item with isEncrypted = true is passed
    public weak var decryptionDelegate: VersaPlayerDecryptionDelegate? = nil
    
    /// VersaPlayer initial container
    private weak var nonFullscreenContainer: View!
    
    #if os(iOS)
    /// AVPictureInPictureController instance
    public var pipController: AVPictureInPictureController? = nil
    #endif

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
    
    #if os(macOS)
    open override var wantsLayer: Bool {
        get { return true } set { }
    }
    #endif
    
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
    
    /// VersaPlayerControls instance to display controls in player, using VersaPlayerGestureRecieverView instance
    /// to handle gestures
    ///
    /// - Parameters:
    ///     - controls: VersaPlayerControls instance used to display controls
    ///     - gestureReciever: Optional gesture reciever view to be used to recieve gestures
    public func use(controls: VersaPlayerControls, with gestureReciever: VersaPlayerGestureRecieverView? = nil) {
        self.controls = controls
        let coordinator = VersaPlayerControlsCoordinator()
        coordinator.player = self
        coordinator.controls = controls
        coordinator.gestureReciever = gestureReciever
        controls.controlsCoordinator = coordinator
        #if os(macOS)
        addSubview(coordinator, positioned: NSWindow.OrderingMode.above, relativeTo: renderingView)
        #else
        addSubview(coordinator)
        bringSubviewToFront(coordinator)
        #endif
    }
    
    /// Update controls to specified time
    ///
    /// - Parameters:
    ///     - time: Time to be updated to
    public func updateControls(toTime time: CMTime) {
        controls?.timeDidChange(toTime: time)
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
        player = VersaPlayer()
        player.handler = self
        player.preparePlayerPlaybackDelegate()
        renderingView = VersaPlayerRenderingView(with: self)
        layout(view: renderingView, into: self)
    }
    
    /// Layout a view within another view stretching to edges
    ///
    /// - Parameters:
    ///     - view: The view to layout.
    ///     - into: The container view.
    open func layout(view: View, into: View? = nil) {
        guard let into = into else {
            return
        }
        into.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: into.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: into.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: into.rightAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: into.bottomAnchor).isActive = true
    }
    
    #if os(iOS)
    /// Enables or disables PIP when available (when device is supported)
    ///
    /// - Parameters:
    ///     - enabled: Whether or not to enable
    open func setNativePip(enabled: Bool) {
        if pipController == nil && renderingView != nil {
            let controller = AVPictureInPictureController(playerLayer: renderingView!.playerLayer)
            controller?.delegate = self
            pipController = controller
        }
        
        if enabled {
            pipController?.startPictureInPicture()
        }else {
            pipController?.stopPictureInPicture()
        }
    }
    #endif
    
    /// Enables or disables fullscreen
    ///
    /// - Parameters:
    ///     - enabled: Whether or not to enable
    open func setFullscreen(enabled: Bool) {
        if enabled == isFullscreenModeEnabled {
            return
        }
        if enabled {
            #if os(macOS)
            if let window = NSApplication.shared.keyWindow {
                nonFullscreenContainer = superview
                removeFromSuperview()
                layout(view: self, into: window.contentView)
            }
            #else
            if let window = UIApplication.shared.keyWindow {
                nonFullscreenContainer = superview
                removeFromSuperview()
                layout(view: self, into: window)
            }
            #endif
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
    open func set(item: VersaPlayerItem?) {
        if !ready {
            prepare()
        }
        
        player.replaceCurrentItem(with: item)
        if autoplay && item?.error == nil {
            play()
        }
    }
    
    /// Play
    @IBAction open func play(sender: Any? = nil) {
        if playbackDelegate?.playbackShouldBegin(player: player) ?? true {
            player.play()
            controls?.playPauseButton?.set(active: true)
            isPlaying = true
        }
    }
    
    /// Pause
    @IBAction open func pause(sender: Any? = nil) {
        player.pause()
        controls?.playPauseButton?.set(active: false)
        isPlaying = false
    }
    
    /// Toggle Playback
    @IBAction open func togglePlayback(sender: Any? = nil) {
        if isPlaying {
            pause()
        }else {
            play()
        }
    }
    
    #if os(iOS)
    open func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("stopped")
        //hide fallback
    }
    
    open func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("started")
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
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print(error.localizedDescription)
    }
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
    }
    #endif
    
}
