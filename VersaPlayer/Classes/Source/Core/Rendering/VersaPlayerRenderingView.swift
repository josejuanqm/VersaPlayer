//
//  VPlayerRenderingView.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import AVKit

open class VersaPlayerRenderingView: View {
    
    /// VPlayerLayer instance used to render player content
    public var renderingLayer: VersaPlayerLayer!
    
    /// VersaPlayer instance being rendered by renderingLayer
    public weak var player: VersaPlayerView!

    deinit {
      #if DEBUG
          print("6 \(String(describing: self))")
      #endif
    }

    /// Constructor
    ///
    /// - Parameters:
    ///     - player: VersaPlayer instance to render.
    public init(with player: VersaPlayerView) {
        super.init(frame: CGRect.zero)
        self.player = player
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    
    open override func layout() {
        super.layout()
        if renderingLayer == nil {
            renderingLayer = VersaPlayerLayer.init(with: player)
            layer = renderingLayer.playerLayer
        }
        
        renderingLayer.playerLayer.frame = bounds
    }
    
    #else
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if renderingLayer == nil {
            renderingLayer = VersaPlayerLayer.init(with: player)
            layer.addSublayer(renderingLayer.playerLayer)
        }
        
        renderingLayer.playerLayer.frame = bounds
    }
    
    #endif
    
}
