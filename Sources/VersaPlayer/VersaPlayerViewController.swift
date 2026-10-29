//
//  VersaPlayerViewController.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit

/// `VersaVideoPlayer` for UIKit apps.
public final class VersaPlayerViewController: UIHostingController<VersaVideoPlayer<DefaultControls>> {
    public let model: VersaPlayerModel

    public init(model: VersaPlayerModel = VersaPlayerModel()) {
        self.model = model
        super.init(rootView: VersaVideoPlayer(model: model))
    }

    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}

#elseif canImport(AppKit)
import AppKit

/// `VersaVideoPlayer` for AppKit apps.
public final class VersaPlayerViewController: NSHostingController<VersaVideoPlayer<DefaultControls>> {
    public let model: VersaPlayerModel

    public init(model: VersaPlayerModel = VersaPlayerModel()) {
        self.model = model
        super.init(rootView: VersaVideoPlayer(model: model))
    }

    @available(*, unavailable)
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
}
#endif
