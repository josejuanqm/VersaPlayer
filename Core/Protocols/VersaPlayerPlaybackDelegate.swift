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
    func timeDidChange(forPlayer player: VPlayer, to time: CMTime)
    func playbackShouldBegin(forPlayer player: VPlayer) -> Bool
    func playbackDidJump(forPlayer player: VPlayer)
    func playbackWillBegin(forPlayer player: VPlayer)
    func playbackReady(forPlayer player: VPlayer)
    func playbackDidBegin(forPlayer player: VPlayer)
    func playbackDidEnd(forPlayer player: VPlayer)
    func playerDidFailToStart(forPlayer player: VPlayer)
    func startBuffering(forPlayer: VPlayer)
    func endBuffering(forPlayer: VPlayer)
}
