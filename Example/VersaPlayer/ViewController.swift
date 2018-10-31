//
//  ViewController.swift
//  VersaPlayer
//
//  Created by jose.juan.qm@gmail.com on 10/13/2018.
//  Copyright (c) 2018 jose.juan.qm@gmail.com. All rights reserved.
//

import UIKit
import VersaPlayer
import CoreMedia

class ViewController: UIViewController {
    
    @IBOutlet weak var player: VersaPlayerView!
    @IBOutlet weak var controls: VersaPlayerControls!

    override func viewDidLoad() {
        super.viewDidLoad()
        player.use(controls: controls)
        if let url = URL.init(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8") {
            let item = VersaPlayerItem(url: url)
            player.set(item: item)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectAudio() {
        if let item = player.player.currentItem as? VersaPlayerItem {
            showOptionsSelector(for: item.audioTracks)
        }
    }
    
    @IBAction func selectVideo() {
        if let item = player.player.currentItem as? VersaPlayerItem {
            showOptionsSelector(for: item.videoTracks)
        }
    }
    
    @IBAction func selectCaption() {
        if let item = player.player.currentItem as? VersaPlayerItem {
            showOptionsSelector(for: item.captionTracks)
        }
    }
    
    func showOptionsSelector(for tracks: [VersaPlayerMediaTrack]) {
        let alert = UIAlertController(title: "Caption", message: "Select your preffered caption track", preferredStyle: UIAlertControllerStyle.actionSheet)
        for track in tracks {
            alert.addAction(
                UIAlertAction.init(title: track.name, style: .default, handler: { (action) in
                    track.select(for: self.player.player)
                })
            )
        }
        alert.addAction(
            UIAlertAction.init(title: "Cancel", style: .destructive, handler: nil)
        )
        
        present(alert, animated: true, completion: nil)
    }

}

