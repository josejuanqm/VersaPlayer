//
//  VPlaybackDelegate.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import AVFoundation

public protocol VersaPlayerPlaybackDelegate {
    
    /// Notifies when playback time changes
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    ///     - time: Current time
    func timeDidChange(forPlayer player: VPlayer, to time: CMTime)
    
    /// Whether if playback should begin on specified player
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    ///
    /// - Returns: Boolean to validate if should play
    func playbackShouldBegin(forPlayer player: VPlayer) -> Bool
    
    /// Whether if playback is skipping frames
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func playbackDidJump(forPlayer player: VPlayer)
    
    /// Notifies when player will begin playback
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func playbackWillBegin(forPlayer player: VPlayer)
    
    /// Notifies when playback is ready to play
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func playbackReady(forPlayer player: VPlayer)
    
    /// Notifies when playback did begin
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func playbackDidBegin(forPlayer player: VPlayer)
    
    /// Notifies when player ended playback
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func playbackDidEnd(forPlayer player: VPlayer)
    
    /// Notifies when player failed to start playback
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func playerDidFailToStart(forPlayer player: VPlayer)
    
    /// Notifies when player starts buffering
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func startBuffering(forPlayer: VPlayer)
    
    /// Notifies when player ends buffering
    ///
    /// - Parameters:
    ///     - player: VPlayer being used
    func endBuffering(forPlayer: VPlayer)
    
}
