//
//  ViewController.swift
//  VersaPlayerTest
//
//  Created by Jose Quintero on 11/5/18.
//  Copyright © 2018 Quasar Studio. All rights reserved.
//

import Cocoa
import VersaPlayer
import AVFoundation

class ViewController: NSViewController {
    
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var controls: VersaPlayerControls!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL.init(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8") {
            let item = VersaPlayerItem(url: url)
            playerView.autoplay = false
            playerView.renderingView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerView.set(item: item)
        }
        
        playerView.layer?.backgroundColor = .black
        playerView.use(controls: controls)
    }


}

