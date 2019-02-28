//
//  VPlaybackDelegate.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import AVFoundation

public protocol VersaPlayerPlaybackDelegate: AnyObject {
    
    /// Notifies when playback time changes
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///     - time: Current time
    func timeDidChange(player: VersaPlayer, to time: CMTime)
    
    /// Whether if playback should begin on specified player
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///
    /// - Returns: Boolean to validate if should play
    func playbackShouldBegin(player: VersaPlayer) -> Bool
    
    /// Whether if playback is skipping frames
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidJump(player: VersaPlayer)
    
    /// Notifies when player will begin playback
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackWillBegin(player: VersaPlayer)
    
    /// Notifies when playback is ready to play
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackReady(player: VersaPlayer)
    
    /// Notifies when playback did begin
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidBegin(player: VersaPlayer)
    
    /// Notifies when player ended playback
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidEnd(player: VersaPlayer)
    
    /// Notifies when player starts buffering
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func startBuffering(player: VersaPlayer)
    
    /// Notifies when player ends buffering
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func endBuffering(player: VersaPlayer)
    
    /// Notifies when playback fails with an error
    ///
    /// - Parameters:
    ///     - error: playback error
    func playbackDidFailed(with error: VersaPlayerPlaybackError)

    /// Notifies when player will pause playback
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackWillPause(player: VersaPlayer)

    /// Notifies when player did pause playback
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    func playbackDidPause(player: VersaPlayer)

    /// Notifies when current VersaPlayerItem is ready to play
    ///
    /// - Parameters:
    ///     - player: VersaPlayer being used
    ///     - item: VersaPlayerItem being used
    func playbackItemReady(player: VersaPlayer, item: VersaPlayerItem?)
    
}

public extension VersaPlayerPlaybackDelegate {

    func timeDidChange(player: VersaPlayer, to time: CMTime) { }

    func playbackShouldBegin(player: VersaPlayer) -> Bool {
      return true
    }

    func playbackDidJump(player: VersaPlayer) { }

    func playbackWillBegin(player: VersaPlayer) { }

    func playbackReady(player: VersaPlayer) { }

    func playbackDidBegin(player: VersaPlayer) { }

    func playbackDidEnd(player: VersaPlayer) { }

    func startBuffering(player: VersaPlayer) { }

    func endBuffering(player: VersaPlayer) { }

    func playbackDidFailed(with error: VersaPlayerPlaybackError) { }

    func playbackWillPause(player: VersaPlayer) { }

    func playbackDidPause(player: VersaPlayer) { }

    func playbackItemReady(player: VersaPlayer, item: VersaPlayerItem?) { }
}
