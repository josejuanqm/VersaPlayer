//
//  VersaPlayer_ExampleTests.swift
//  VersaPlayer_ExampleTests
//
//  Created by Jose Quintero on 10/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import VersaPlayer

class VersaPlayer_ExampleTests: XCTestCase {

    var player: VersaPlayerView = VersaPlayerView(frame: .zero)
    var container: UIView = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
    
    func testItemSet() {
        if let url = URL.init(string: "http://rmcdn.2mdn.net/Demo/html5/output.mp4") {
            let item = VersaPlayerItem(url: url)
            self.player.set(item: item)
            XCTAssertNotNil(self.player.player.currentItem)
        }
    }
    
    func testCanPlay() {
        self.player.play()
        XCTAssertTrue(self.player.isPlaying)
    }
    
    func testCanPause() {
        if self.player.isPlaying {
            self.player.pause()
            XCTAssertTrue(!self.player.isPlaying)
        }
    }

}
