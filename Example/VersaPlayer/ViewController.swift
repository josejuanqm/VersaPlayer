//
//  ViewController.swift
//  VersaPlayer
//
//  Created by jose.juan.qm@gmail.com on 10/13/2018.
//  Copyright (c) 2018 jose.juan.qm@gmail.com. All rights reserved.
//

import UIKit
import VersaPlayer

class ViewController: UIViewController {
    
    @IBOutlet weak var player: VersaPlayer!
    @IBOutlet weak var controls: VersaPlayerControls!

    override func viewDidLoad() {
        super.viewDidLoad()
        player.use(controls: controls)
        if let url = URL.init(string: "http://rmcdn.2mdn.net/Demo/html5/output.mp4") {
            let item = VPlayerItem(url: url)
            player.set(item: item)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

