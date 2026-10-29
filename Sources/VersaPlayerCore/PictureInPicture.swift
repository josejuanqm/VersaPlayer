//
//  PictureInPicture.swift
//  VersaPlayer
//
//  Created by Jose Quintero on 10/28/26.
//

import AVFoundation

#if !os(visionOS)
import AVKit

@MainActor
final class PictureInPictureCoordinator: NSObject, @preconcurrency AVPictureInPictureControllerDelegate {
    private weak var model: VersaPlayerModel?
    private let controller: AVPictureInPictureController
    private var possibleObservation: NSKeyValueObservation?

    init?(layer: AVPlayerLayer, model: VersaPlayerModel) {
        guard AVPictureInPictureController.isPictureInPictureSupported(),
              let controller = AVPictureInPictureController(playerLayer: layer) else { return nil }
        self.controller = controller
        self.model = model
        super.init()
        controller.delegate = self
        #if os(iOS)
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        #endif
        possibleObservation = controller.observe(\.isPictureInPicturePossible, options: [.initial, .new]) { @Sendable [weak model] controller, _ in
            let possible = controller.isPictureInPicturePossible
            let target = model
            onMain { target?.isPictureInPicturePossible = possible }
        }
    }

    var playerLayer: AVPlayerLayer { controller.playerLayer }

    func start() { controller.startPictureInPicture() }
    func stop() { controller.stopPictureInPicture() }

    func pictureInPictureControllerWillStartPictureInPicture(_ controller: AVPictureInPictureController) {
        model?.isPictureInPictureActive = true
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
        model?.isPictureInPictureActive = false
    }

    func pictureInPictureController(_ controller: AVPictureInPictureController, failedToStartPictureInPictureWithError error: any Error) {
        model?.isPictureInPictureActive = false
    }

    func pictureInPictureController(
        _ controller: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(true)
    }
}

extension VersaPlayerModel {
    package func attachPictureInPicture(to layer: AVPlayerLayer) {
        guard pictureInPicture?.playerLayer !== layer else { return }
        pictureInPicture = PictureInPictureCoordinator(layer: layer, model: self)
        if pictureInPicture == nil { isPictureInPicturePossible = false }
    }

    public func startPictureInPicture() { pictureInPicture?.start() }
    public func stopPictureInPicture() { pictureInPicture?.stop() }

    public func togglePictureInPicture() {
        isPictureInPictureActive ? stopPictureInPicture() : startPictureInPicture()
    }
}

#else

@MainActor
final class PictureInPictureCoordinator {}

extension VersaPlayerModel {
    package func attachPictureInPicture(to layer: AVPlayerLayer) {}
    public func startPictureInPicture() {}
    public func stopPictureInPicture() {}
    public func togglePictureInPicture() {}
}

#endif
