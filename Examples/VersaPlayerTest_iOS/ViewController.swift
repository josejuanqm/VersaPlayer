//
//  ViewController.swift
//  VersaPlayerTest_ios
//
//  Created by Jose Quintero on 11/5/18.
//  Copyright © 2018 Quasar Studio. All rights reserved.
//

import UIKit
import VersaPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var controls: VersaPlayerControls!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView.layer.backgroundColor = UIColor.black.cgColor
        playerView.use(controls: controls)
        playerView.controls?.behaviour.shouldAutohide = true
        
        if let url = URL.init(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8") {
            let item = VersaPlayerItem(url: url)
            playerView.set(item: item)
        }
    }


}

