//
//  VersaPlayerControls.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

open class VersaPlayerControls: UIView {
    
    /// VersaPlayer intance being controlled
    public var handler: VersaPlayer!
    
    /// VersaPlayerControlsBehaviour being used to validate ui
    public var behaviour: VersaPlayerControlsBehaviour!
    
    /// VersaPlayerControlsCoordinator instance
    public var controlsCoordinator: VersaPlayerControlsCoordinator!
    
    /// VersaStatefulButton instance to represent the play/pause button
    @IBOutlet public weak var playPauseButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the fullscreen toggle button
    @IBOutlet public weak var fullscreenButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the PIP button
    @IBOutlet public weak var pipButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the rewind button
    @IBOutlet public weak var rewindButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the forward button
    @IBOutlet public weak var forwardButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the skip forward button
    @IBOutlet public weak var skipForwardButton: VersaStatefulButton? = nil
    
    /// VersaStatefulButton instance to represent the skip backward button
    @IBOutlet public weak var skipBackwardButton: VersaStatefulButton? = nil
    
    /// VersaSeekbarSlider instance to represent the seekbar slider
    @IBOutlet public weak var seekbarSlider: VersaSeekbarSlider? = nil
    
    /// VersaTimeLabel instance to represent the current time label
    @IBOutlet public weak var currentTimeLabel: VersaTimeLabel? = nil
    
    /// VersaTimeLabel instance to represent the total time label
    @IBOutlet public weak var totalTimeLabel: VersaTimeLabel? = nil
    
    /// UIView to be shown when buffering
    @IBOutlet public weak var bufferingView: UIView? = nil
    
    private var wasPlayingBeforeRewinding: Bool = false
    private var wasPlayingBeforeForwarding: Bool = false
    private var wasPlayingBeforeSeeking: Bool = false
    
    /// Skip size in seconds to be used for skipping forward or backwards
    public var skipSize: Double = 30
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: VPlayer.VPlayerNotificationName.timeChanged.notification, object: nil)
        NotificationCenter.default.removeObserver(self, name: VPlayer.VPlayerNotificationName.play.notification, object: nil)
        NotificationCenter.default.removeObserver(self, name: VPlayer.VPlayerNotificationName.pause.notification, object: nil)
        NotificationCenter.default.removeObserver(self, name: VPlayer.VPlayerNotificationName.buffering.notification, object: nil)
        NotificationCenter.default.removeObserver(self, name: VPlayer.VPlayerNotificationName.endBuffering.notification, object: nil)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        behaviour.hide()
    }

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let h = superview as? VersaPlayerControlsCoordinator {
            handler = h.player
            if behaviour == nil {
                behaviour = VersaPlayerControlsBehaviour(with: self)
            }
            prepare()
        }
    }
    
    /// Notifies when time changes
    ///
    /// - Parameters:
    ///     - time: CMTime representation of the current playback time
    public func timeDidChange(toTime time: CMTime) {
        currentTimeLabel?.update(toTime: time.seconds)
        totalTimeLabel?.update(toTime: handler.player.endTime().seconds)
        seekbarSlider?.minimumValue = Float(handler.player.startTime().seconds)
        seekbarSlider?.maximumValue = Float(handler.player.endTime().seconds)
        seekbarSlider?.value = Float(time.seconds)
        
        if !(handler.isSeeking || handler.isRewinding || handler.isForwarding) {
            behaviour.update(with: time.seconds)
        }
    }
    
    /// Remove coordinator from player
    public func removeFromPlayer() {
        controlsCoordinator.removeFromSuperview()
    }
    
    /// Prepare controls targets and notification listeners
    public func prepare() {
        layout()
        
        playPauseButton?.addTarget(self, action: #selector(togglePlayback), for: .touchUpInside)
        
        fullscreenButton?.addTarget(self, action: #selector(toggleFullscreen), for: .touchUpInside)
        
        if !AVPictureInPictureController.isPictureInPictureSupported() {
            pipButton?.alpha = 0.3
            pipButton?.isUserInteractionEnabled = false
        }else {
            pipButton?.addTarget(self, action: #selector(togglePip), for: .touchUpInside)
        }
        
        rewindButton?.addTarget(self, action: #selector(rewindToggle), for: .touchUpInside)
        
        forwardButton?.addTarget(self, action: #selector(forwardToggle), for: .touchUpInside)
        
        skipForwardButton?.addTarget(self, action: #selector(skipForward), for: .touchUpInside)
        skipBackwardButton?.addTarget(self, action: #selector(skipBackward), for: .touchUpInside)
        
        prepareSeekbar()
        seekbarSlider?.addTarget(self, action: #selector(playheadChanged(with:)), for: .valueChanged)
        seekbarSlider?.addTarget(self, action: #selector(seekingEnd), for: .touchUpInside)
        seekbarSlider?.addTarget(self, action: #selector(seekingEnd), for: .touchUpOutside)
        seekbarSlider?.addTarget(self, action: #selector(seekingStart), for: .touchDown)
        
        prepareNotificationListener()
    }
    
    /// Layout in parent view
    public func layout() {
        translatesAutoresizingMaskIntoConstraints = false
        if let parent = superview {
            topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
            leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
            bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
        }
    }
    
    /// Prepares the notification observers/listeners
    public func prepareNotificationListener() {
        NotificationCenter.default.addObserver(forName: VPlayer.VPlayerNotificationName.timeChanged.notification, object: nil, queue: OperationQueue.main) { (notification) in
            if let time = notification.userInfo?[VPlayer.VPlayerNotificationInfoKey.time.rawValue] as? CMTime {
                self.timeDidChange(toTime: time)
            }
        }
        NotificationCenter.default.addObserver(forName: VPlayer.VPlayerNotificationName.didEnd.notification, object: nil, queue: OperationQueue.main) { (notification) in
            self.playPauseButton?.set(active: false)
        }
        NotificationCenter.default.addObserver(forName: VPlayer.VPlayerNotificationName.play.notification, object: nil, queue: OperationQueue.main) { (notification) in
            self.playPauseButton?.set(active: true)
        }
        NotificationCenter.default.addObserver(forName: VPlayer.VPlayerNotificationName.pause.notification, object: nil, queue: OperationQueue.main) { (notification) in
            self.playPauseButton?.set(active: false)
        }
        NotificationCenter.default.addObserver(forName: VPlayer.VPlayerNotificationName.endBuffering.notification, object: nil, queue: OperationQueue.main) { (notification) in
            self.hideBuffering()
        }
        NotificationCenter.default.addObserver(forName: VPlayer.VPlayerNotificationName.buffering.notification, object: nil, queue: OperationQueue.main) { (notification) in
            self.showBuffering()
        }
    }
    
    /// Prepare the seekbar values
    public func prepareSeekbar() {
        seekbarSlider?.value = Float(handler.player.currentTime().seconds)
        seekbarSlider?.minimumValue = Float(handler.player.startTime().seconds)
        seekbarSlider?.maximumValue = Float(handler.player.endTime().seconds)
    }
    
    /// Show buffering view
    public func showBuffering() {
        bufferingView?.isHidden = false
    }
    
    /// Hide buffering view
    public func hideBuffering() {
        bufferingView?.isHidden = true
    }
    
    /// Skip forward (n) seconds in time
    @IBAction public func skipForward() {
        let time = handler.player.currentTime() + CMTime(seconds: skipSize, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        handler.player.seek(to: time)
    }
    
    /// Skip backward (n) seconds in time
    @IBAction public func skipBackward() {
        let time = handler.player.currentTime() - CMTime(seconds: skipSize, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        handler.player.seek(to: time)
    }
    
    /// End seeking
    @IBAction public func seekingEnd() {
        handler.isSeeking = false
        if wasPlayingBeforeSeeking {
            handler.play()
        }
    }
    
    /// Start Seeking
    @IBAction public func seekingStart() {
        wasPlayingBeforeSeeking = handler.isPlaying
        handler.isSeeking = true
        handler.pause()
    }
    
    /// Playhead changed in UISlider
    ///
    /// - Parameters:
    ///     - sender: UISlider that updated
    @IBAction public func playheadChanged(with sender: UISlider) {
        let value = Double(sender.value)
        let time = CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        handler.player.seek(to: time)
        behaviour.update(with: time.seconds)
    }
    
    /// Toggle PIP mode
    @IBAction public func togglePip() {
        handler.setNativePip(enabled: !handler.isPipModeEnabled)
    }
    
    /// Toggle fullscreen mode
    @IBAction public func toggleFullscreen() {
        fullscreenButton?.set(active: !handler.isFullscreenModeEnabled)
        handler.setFullscreen(enabled: !handler.isFullscreenModeEnabled)
    }
    
    /// Toggle playback
    @IBAction public func togglePlayback() {
        if handler.isRewinding || handler.isForwarding {
            handler.player.rate = 1
            playPauseButton?.set(active: true)
            return;
        }
        if handler.isPlaying {
            playPauseButton?.set(active: false)
            handler.pause()
        }else {
            if handler.playbackDelegate?.playbackShouldBegin(forPlayer: handler.player) ?? true {
                playPauseButton?.set(active: true)
                handler.play()
            }
        }
    }
    
    /// Toggle rewind
    @IBAction public func rewindToggle() {
        if handler.player.currentItem?.canPlayFastReverse ?? false {
            if handler.isRewinding {
                rewindButton?.set(active: false)
                handler.player.rate = 1
                if wasPlayingBeforeRewinding {
                    handler.play()
                }else {
                    handler.pause()
                }
            }else {
                playPauseButton?.set(active: false)
                rewindButton?.set(active: true)
                wasPlayingBeforeRewinding = handler.isPlaying
                if !handler.isPlaying {
                    handler.play()
                }
                handler.player.rate = -1
            }
        }
    }
    
    /// Forward toggle
    @IBAction public func forwardToggle() {
        if handler.player.currentItem?.canPlayFastForward ?? false {
            if handler.isForwarding {
                forwardButton?.set(active: false)
                handler.player.rate = 1
                if wasPlayingBeforeForwarding {
                    handler.play()
                }else {
                    handler.pause()
                }
            }else {
                playPauseButton?.set(active: false)
                forwardButton?.set(active: true)
                wasPlayingBeforeForwarding = handler.isPlaying
                if !handler.isPlaying {
                    handler.play()
                }
                handler.player.rate = 2
            }
        }
    }

}
