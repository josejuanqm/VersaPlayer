//
//  VersaPlayerDemoApp.swift
//  VersaPlayerDemo
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import SwiftUI

@main
struct VersaPlayerDemoApp: App {
    init() {
        #if os(iOS) || os(tvOS) || os(visionOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
