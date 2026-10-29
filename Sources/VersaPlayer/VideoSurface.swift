//
//  VideoSurface.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation
import SwiftUI

/// Video only, no controls.
public struct VideoSurface: View {
    private let model: VersaPlayerModel
    private let gravity: AVLayerVideoGravity

    public init(model: VersaPlayerModel, gravity: AVLayerVideoGravity = .resizeAspect) {
        self.model = model
        self.gravity = gravity
    }

    public var body: some View {
        PlayerLayerRepresentable(player: model.player, gravity: gravity) { layer in
            model.attachPictureInPicture(to: layer)
        }
        .accessibilityHidden(true)
    }
}

#if canImport(UIKit)
import UIKit

final class PlayerLayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

private struct PlayerLayerRepresentable: UIViewRepresentable {
    let player: AVPlayer
    let gravity: AVLayerVideoGravity
    let onLayer: (AVPlayerLayer) -> Void

    func makeUIView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.backgroundColor = .clear
        view.playerLayer.player = player
        view.playerLayer.videoGravity = gravity
        onLayer(view.playerLayer)
        return view
    }

    func updateUIView(_ view: PlayerLayerView, context: Context) {
        if view.playerLayer.player !== player {
            view.playerLayer.player = player
            onLayer(view.playerLayer)
        }
        view.playerLayer.videoGravity = gravity
    }
}

#elseif canImport(AppKit)
import AppKit

final class PlayerLayerView: NSView {
    let playerLayer = AVPlayerLayer()

    override init(frame: NSRect) {
        super.init(frame: frame)
        layer = playerLayer
        wantsLayer = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
}

private struct PlayerLayerRepresentable: NSViewRepresentable {
    let player: AVPlayer
    let gravity: AVLayerVideoGravity
    let onLayer: (AVPlayerLayer) -> Void

    func makeNSView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = gravity
        onLayer(view.playerLayer)
        return view
    }

    func updateNSView(_ view: PlayerLayerView, context: Context) {
        if view.playerLayer.player !== player {
            view.playerLayer.player = player
            onLayer(view.playerLayer)
        }
        view.playerLayer.videoGravity = gravity
    }
}
#endif
