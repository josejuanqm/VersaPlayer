# Migrating from 3.x to 4.0

4.0 is a SwiftUI rewrite. Requirements went up: iOS/tvOS 17, macOS 14, visionOS 1, Swift 6. Swift Package Manager only (CocoaPods and Carthage are gone). The last 3.x release is tag `3.0.2`.

## Concepts

| 3.x | 4.0 |
|---|---|
| `VersaPlayerView` (UIView/NSView) | `VersaVideoPlayer(model:)` (SwiftUI) + `VersaPlayerModel` |
| `VersaPlayer` (AVPlayer subclass) | `VersaPlayerModel.player` (plain `AVPlayer`) |
| `playerView.set(item:)` | `model.load(_:autoplay:)` |
| `VersaPlayerItem(url:)` (AVPlayerItem subclass) | `VersaPlayerItem(url:)` (value type: url, drm, startTime, captionStyle, quality, metadata) |
| `isPlaying` (set by hand) | `model.isPlaying` (from `timeControlStatus`) |
| `autoplay` property | `load(_:autoplay:)` argument |
| `VersaPlayerPlaybackDelegate` | Observable properties + `model.events` (`AsyncStream<PlaybackEvent>`) |
| `playbackShouldBegin(player:)` | `model.shouldBeginPlayback` (async closure) |
| `VPlayerNotificationName` notifications | `model.events` |
| `VersaPlayerPlaybackError` | `PlaybackError` (same cases, plus `.contentKey` and `.underlying`) |
| `VersaPlayerControls` + IB outlets | `DefaultControls`, or your own view built from the building blocks |
| `VersaStatefulButton` / `VersaSeekbarSlider` / `VersaTimeLabel` | `PlayPauseButton`, `SkipButton`, `RateButton`, `Scrubber`, `TimeLabel` |
| `bufferingView` outlet | `BufferingIndicator` |
| `VersaPlayerControlsBehaviour` (autohide off by default) | `ControlsVisibility` and `.controlsAutohide(after:)` (on by default, 3s) |
| `skipSize` | `SkipButton(seconds:)` |
| `VersaPlayerGestureRecieverView` / coordinator | Built in: tap, double tap, hover, keyboard, Siri Remote |
| `didSwipe(with:)` override (tvOS) | Built in: focus-driven scrubbing and menus; custom controls use `.controlsTakeFocus()` |
| `setFullscreen(enabled:)` | `.onFullscreenRequest { }`; your app presents fullscreen |
| `setNativePip(enabled:)` | `model.togglePictureInPicture()` / `PiPButton` |
| `airplayContainer` outlet | `AirPlayButton` |
| `currentItem.audioTracks` etc. | `model.tracks(of: .audio / .legible / .video)` |
| `track.select(for: player)` | `model.select(track)` / `model.deselect(.legible)` |
| `currentMediaTrack(for:)` | `model.selectedTracks[kind]` |
| `player.captionStyling.set(...)` | `model.setCaptionStyle(CaptionStyle)` |
| `VersaPlayerDecryptionDelegate` (3 URLs) | `FairPlayHTTPProvider(certificateURL:licenseURL:contentID:)` or your own `ContentKeyProvider` |
| `isEncrypted = true` | `VersaPlayerItem(url:, drm: DRMConfiguration(provider:))` |
| `VersaPlayerExtension` + `addExtension(extension:with:)` | `VersaPlayerPlugin` + `model.add(_:)` |
| `renderingView.playerLayer.videoGravity` | `.videoGravity(_:)` |

## Before / after

```swift
// 3.x
playerView.use(controls: controls)
playerView.playbackDelegate = self
playerView.set(item: VersaPlayerItem(url: url))

// 4.0
@State private var model = VersaPlayerModel()

VersaVideoPlayer(model: model)
    .task {
        model.load(VersaPlayerItem(url: url))
        for await event in model.events { handle(event) }
    }
```

UIKit apps can use `VersaPlayerViewController(model:)`.

## Removed

- The external AirPlay, Ads and Overlay Content extension repos target the 3.x extension API and don't work with 4.0.
- `VersaPlayerView.extensions` dictionary lookup → `model.plugin(of: MyPlugin.self)`.
