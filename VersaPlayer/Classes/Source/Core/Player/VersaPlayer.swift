//
//  VersaPlayer.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import AVFoundation

open class VersaPlayer: AVPlayer, AVAssetResourceLoaderDelegate {
    
    /// Dispatch queue for resource loader
    private let queue = DispatchQueue(label: "quasar.studio.versaplayer")
    
    /// Notification key to extract info
    public enum VPlayerNotificationInfoKey: String {
        case time = "VERSA_PLAYER_TIME"
    }
    
    /// Notification name to post
    public enum VPlayerNotificationName: String {
        case assetLoaded = "VERSA_ASSET_ADDED"
        case timeChanged = "VERSA_TIME_CHANGED"
        case willPlay = "VERSA_PLAYER_STATE_WILL_PLAY"
        case play = "VERSA_PLAYER_STATE_PLAY"
        case pause = "VERSA_PLAYER_STATE_PAUSE"
        case buffering = "VERSA_PLAYER_BUFFERING"
        case endBuffering = "VERSA_PLAYER_END_BUFFERING"
        case didEnd = "VERSA_PLAYER_END_PLAYING"

        /// Notification name representation
        public var notification: NSNotification.Name {
            return NSNotification.Name.init(self.rawValue)
        }
    }
    
    /// VersaPlayer instance
    public weak var handler: VersaPlayerView?
    
    /// Caption text style rules
    lazy public var captionStyling: VersaPlayerCaptionStyling = {
        return VersaPlayerCaptionStyling(with: self)
    }()
    
    /// Whether player is buffering
    public var isBuffering: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemTimeJumped, object: self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self)
        removeObserver(self, forKeyPath: "status")
    }
    
    /// Play content
    override open func play() {
        self.handler?.playbackDelegate?.playbackWillBegin(player: self)
        NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.willPlay.notification, object: self, userInfo: nil)
        if !(self.handler?.playbackDelegate?.playbackShouldBegin(player: self) ?? true) {
            return
        }
        NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.play.notification, object: self, userInfo: nil)
        super.play()
        self.handler?.playbackDelegate?.playbackDidBegin(player: self)
    }
    
    /// Pause content
    override open func pause() {
        self.handler?.playbackDelegate?.playbackWillPause(player: self)
        NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.pause.notification, object: self, userInfo: nil)
        super.pause()
        self.handler?.playbackDelegate?.playbackDidPause(player: self)
    }
    
    /// Replace current item with a new one
    ///
    /// - Parameters:
    ///     - item: AVPlayer item instance to be added
    override open func replaceCurrentItem(with item: AVPlayerItem?) {
        if let asset = item?.asset as? AVURLAsset, let vitem = item as? VersaPlayerItem, vitem.isEncrypted {
            asset.resourceLoader.setDelegate(self, queue: queue)
        }
        
        currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        currentItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        currentItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        currentItem?.removeObserver(self, forKeyPath: "status")
        
        super.replaceCurrentItem(with: item)
        
        NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.assetLoaded.notification, object: self, userInfo: nil)

        if let newItem = currentItem ?? item {
            newItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            newItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            newItem.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
            newItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        }
    }
}

extension VersaPlayer {
    
    /// Start time
    ///
    /// - Returns: Player's current item start time as CMTime
    open func startTime() -> CMTime {
        guard let item = currentItem else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
        
        if item.reversePlaybackEndTime.isValid {
            return item.reversePlaybackEndTime
        } else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
    }
    
    /// End time
    ///
    /// - Returns: Player's current item end time as CMTime
    open func endTime() -> CMTime {
        guard let item = currentItem else {
            return CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        }
        
        if item.forwardPlaybackEndTime.isValid {
            return item.forwardPlaybackEndTime
        } else {
            if item.duration.isValid && !item.duration.isIndefinite {
                return item.duration
            } else {
                return item.currentTime()
            }
        }
    }
    @objc private func playerDidEnd(_ notification:Notification){

        if let item = notification.object as? AVPlayerItem, item == self.currentItem{
            NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.didEnd.notification, object: self, userInfo: nil)
            self.handler?.playbackDelegate?.playbackDidEnd(player: self)
        }
    }
    /// Prepare players playback delegate observers
    open func preparePlayerPlaybackDelegate() {
     NotificationCenter.default.addObserver(self, selector: #selector(playerDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.currentItem)
      NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemTimeJumped, object: self, queue: OperationQueue.main) { [weak self] (notification) in
        guard let self = self else { return }
        self.handler?.playbackDelegate?.playbackDidJump(player: self)
      }
      addPeriodicTimeObserver(
        forInterval: CMTime(
          seconds: 1,
          preferredTimescale: CMTimeScale(NSEC_PER_SEC)
        ),
        queue: DispatchQueue.main) { [weak self] (time) in
          guard let self = self else { return }
          NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.timeChanged.notification, object: self, userInfo: [VPlayerNotificationInfoKey.time.rawValue: time])
          self.handler?.playbackDelegate?.timeDidChange(player: self, to: time)
      }

      addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    /// Value observer
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let obj = object as? VersaPlayer, obj == self {
            if keyPath == "status" {
                switch status {
                case AVPlayer.Status.readyToPlay:
                    NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.timeChanged.notification, object: self, userInfo: [VPlayerNotificationInfoKey.time.rawValue: CMTime.zero])
                    self.handler?.playbackDelegate?.playbackReady(player: self)
                case AVPlayer.Status.failed:
                    self.handler?.playbackDelegate?.playbackDidFailed(with: VersaPlayerPlaybackError.unknown)
                default:
                    break;
                }
            }
        } else {
            switch keyPath ?? "" {
            case "status":
                if let value = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: value), let item = object as? AVPlayerItem {
                    if status == .failed, let error = item.error as NSError?, let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                        let playbackError: VersaPlayerPlaybackError
                        switch underlyingError.code {
                        case -12937:
                            playbackError = .authenticationError
                        case -16840:
                            playbackError = .unauthorized
                        case -12660:
                            playbackError = .forbidden
                        case -12938:
                            playbackError = .notFound
                        case -12661:
                            playbackError = .unavailable
                        case -12645, -12889:
                            playbackError = .mediaFileError
                        case -12318:
                            playbackError = .bandwidthExceeded
                        case -12642:
                            playbackError = .playlistUnchanged
                        case -12911:
                            playbackError = .decoderMalfunction
                        case -12913:
                            playbackError = .decoderTemporarilyUnavailable
                        case -1004:
                            playbackError = .wrongHostIP
                        case -1003:
                            playbackError = .wrongHostDNS
                        case -1000:
                            playbackError = .badURL
                        case -1202:
                            playbackError = .invalidRequest
                        default:
                            playbackError = .unknown
                        }
                        self.handler?.playbackDelegate?.playbackDidFailed(with: playbackError)
                    }

                    if status == .readyToPlay, let currentItem = self.currentItem as? VersaPlayerItem {
                      self.handler?.playbackDelegate?.playbackItemReady(player: self, item: currentItem)
                    }
                }
            case "playbackBufferEmpty":
                self.isBuffering = true
                NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.buffering.notification, object: self, userInfo: nil)
                self.handler?.playbackDelegate?.startBuffering(player: self)
            case "playbackLikelyToKeepUp":
                self.isBuffering = false
                NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.endBuffering.notification, object: self, userInfo: nil)
                self.handler?.playbackDelegate?.endBuffering(player: self)
                if let item = self.currentItem as? VersaPlayerItem {
                    NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.timeChanged.notification, object: self, userInfo: [VPlayerNotificationInfoKey.time.rawValue: item.currentTime()])
                }
            case "playbackBufferFull":
                self.isBuffering = false
                NotificationCenter.default.post(name: VersaPlayer.VPlayerNotificationName.endBuffering.notification, object: self, userInfo: nil)
                self.handler?.playbackDelegate?.endBuffering(player: self)
            default:
                break;
            }
        }
    }
    
    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url else {
            print("VersaPlayerResourceLoadingError", #function, "Unable to read the url/host data.")
            loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -1, userInfo: nil))
            return false
        }
        
        print("VersaPlayerResourceLoading: \(url)")
        
        guard
            let certificateURL = self.handler?.decryptionDelegate?.urlFor(player: self),
            let certificateData = try? Data(contentsOf: certificateURL) else {
                print("VersaPlayerResourceLoadingError", #function, "Unable to read the certificate data.")
                loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -2, userInfo: nil))
                return false
        }
        
        let contentId = self.handler?.decryptionDelegate?.contentIdFor(player: self) ?? ""
        guard
            let contentIdData = contentId.data(using: String.Encoding.utf8),
            let spcData = try? loadingRequest.streamingContentKeyRequestData(forApp: certificateData, contentIdentifier: contentIdData, options: nil),
            let dataRequest = loadingRequest.dataRequest else {
                loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -3, userInfo: nil))
                print("VersaPlayerResourceLoadingError", #function, "Unable to read the SPC data.")
                return false
        }
        
        guard let ckcURL = self.handler?.decryptionDelegate?.contentKeyContextURLFor(player: self) else {
            loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -4, userInfo: nil))
            print("VersaPlayerResourceLoadingError", #function, "Unable to read the ckcURL.")
            return false
        }
        var request = URLRequest(url: ckcURL)
        request.httpMethod = "POST"
        request.httpBody = spcData
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                dataRequest.respond(with: data)
                loadingRequest.finishLoading()
            } else {
                print("VersaPlayerResourceLoadingError", #function, "Unable to fetch the CKC.")
                loadingRequest.finishLoading(with: NSError(domain: "quasar.studio.error", code: -5, userInfo: nil))
            }
        }
        task.resume()
        
        return true
    }
    
}
