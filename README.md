[![CI](https://github.com/josejuanqm/VersaPlayer/actions/workflows/ci.yml/badge.svg)](https://github.com/josejuanqm/VersaPlayer/actions/workflows/ci.yml)
![Platforms](https://img.shields.io/badge/platforms-iOS%2017%20%7C%20tvOS%2017%20%7C%20macOS%2014%20%7C%20visionOS%201-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

<p align="center">
  <img src="https://github.com/josejuanqm/VersaPlayer/blob/master/Image.png" />
</p>

### News
##### :tada: VersaPlayer 4.0 is a SwiftUI rewrite. Coming from 3.x? See [MIGRATION.md](MIGRATION.md).

---

VersaPlayer is a SwiftUI video player built on AVFoundation: an observable player model, a ready-made controls overlay, and building blocks for your own controls. Supports HLS, tracks, caption styling, FairPlay, Picture in Picture and AirPlay on iOS, tvOS, macOS and visionOS.

## Installation

Swift Package Manager:

```swift
.package(url: "https://github.com/josejuanqm/VersaPlayer.git", from: "4.0.0")
```

Or in Xcode: File › Add Package Dependencies… and paste the repository URL.

## Usage

### Basic

```swift
import SwiftUI
import VersaPlayer

struct PlayerScreen: View {
    @State private var model = VersaPlayerModel()

    var body: some View {
        VersaVideoPlayer(model: model)
            .aspectRatio(16 / 9, contentMode: .fit)
            .task { model.load(VersaPlayerItem(url: url)) }
    }
}
```

`load` autoplays by default. Pass `autoplay: false` to start paused.

### State and events

`VersaPlayerModel` is `@Observable`, so views update on their own:

```swift
model.isPlaying, model.isBuffering, model.currentTime, model.duration, model.isLive, model.status
```

For one-off events (ready, ended, failed, ...):

```swift
.task {
    for await event in model.events {
        if case .failed(let error) = event { print(error) }
    }
}
```

To block playback (for example, to show an ad first):

```swift
model.shouldBeginPlayback = { _ in
    await ads.playPreRoll()
    return true
}
```

### Custom controls

Pass any view as controls. Use the building blocks, which read the player from the environment:

```swift
VersaVideoPlayer(model: model) {
    VStack {
        Spacer()
        HStack {
            PlayPauseButton()
            Scrubber()
            TimeLabel(.remaining)
            TrackPicker(.legible)
        }
        .padding()
    }
}
```

Building blocks: `PlayPauseButton`, `SkipButton(seconds:)`, `RateButton(rate:)`, `Scrubber`, `TimeLabel`, `BufferingIndicator`, `TrackPicker`, `PiPButton`, `AirPlayButton`, `FullscreenButton`.
For video without any overlay, use `VideoSurface(model:)`.

### Options

```swift
VersaVideoPlayer(model: model)
    .videoGravity(.resizeAspectFill)
    .controlsAutohide(after: .seconds(5))   // nil keeps controls visible
    .doubleTapTogglesGravity(false)
```

### Fullscreen

The player asks your app to toggle fullscreen; your app presents it. The fullscreen button appears once you register the request:

```swift
@State private var isFullscreen = false

VersaVideoPlayer(model: model)
    .onFullscreenRequest(isFullscreen: false) { isFullscreen = true }
    .fullScreenCover(isPresented: $isFullscreen) {
        VersaVideoPlayer(model: model)
            .onFullscreenRequest(isFullscreen: true) { isFullscreen = false }
            .ignoresSafeArea()
    }
```

### Tracks

```swift
model.tracks(of: .audio)        // [MediaTrack]
model.tracks(of: .legible)      // subtitles and captions
model.select(track)
model.deselect(.legible)        // subtitles off
model.selectedTracks[.audio]
```

For adaptive (HLS) quality caps:

```swift
model.setQuality(QualityPreference(peakBitRate: 2_000_000))
```

### Caption styling

```swift
var style = CaptionStyle()
style.foregroundColor = .init(red: 1, green: 0.85, blue: 0)
style.relativeFontSize = 150
style.edgeStyle = .dropShadow
model.setCaptionStyle(style)
```

### FairPlay

```swift
let provider = FairPlayHTTPProvider(
    certificateURL: URL(string: "https://example.com/fps/cert")!,
    licenseURL: URL(string: "https://example.com/fps/license")!
)
model.load(VersaPlayerItem(url: url, drm: DRMConfiguration(provider: provider)))
```

For a custom license protocol, implement `ContentKeyProvider`. The FairPlay flow is unit tested with fakes only; test it against your own license server.

### tvOS

The default controls work with the Siri Remote. While the controls are hidden, select shows them, left/right skips 10 seconds, and play/pause toggles playback. While they're visible, the seek bar has focus: left/right scrubs (faster with quick repeated presses), and select jumps there. Swipe up for audio, subtitles and Picture in Picture. Menu hides the controls.

Custom controls with focusable buttons should add `.controlsTakeFocus()`, so focus moves into them while they're visible.

### Picture in Picture and AirPlay

`PiPButton` and `AirPlayButton` are in the default controls. For Picture in Picture on iOS, enable the Audio background mode and set the audio session category to `.playback`.

### Plugins

```swift
final class Analytics: VersaPlayerPlugin {
    func attach(to model: VersaPlayerModel) {
        Task { for await event in model.events { track(event) } }
    }
}
model.add(Analytics())
```

Built in: `NowPlayingPlugin` shows the title, artwork and progress on the lock screen and in Control Center, and handles remote play/pause/skip/seek. It uses `VersaPlayerItem.metadata`:

```swift
model.add(NowPlayingPlugin())
model.load(VersaPlayerItem(url: url, metadata: .init(title: "Episode 1", subtitle: "My Show", artworkURL: artwork)))
```

### UIKit / AppKit

```swift
let controller = VersaPlayerViewController()
controller.model.load(VersaPlayerItem(url: url))
```

## Example

```bash
brew install xcodegen
cd Examples/VersaPlayerDemo && xcodegen generate && open VersaPlayerDemo.xcodeproj
```

One app target for iOS, tvOS, macOS and visionOS.

## Author

Jose Quintero - jose.juan.qm@gmail.com

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=josejuanqm/VersaPlayer&type=Date)](https://www.star-history.com/#josejuanqm/VersaPlayer&Date)

## Contributors

People that make VersaPlayer possible, Thank you!

<span><a href="https://github.com/josejuanqm"><img src="https://github.com/josejuanqm.png" alt="josejuanqm" width="50px"></a></span>
<span><a href="https://github.com/pbeast"><img src="https://github.com/pbeast.png" alt="pbeast" width="50px"></a></span>
<span><a href="https://github.com/danibachar"><img src="https://github.com/danibachar.png" alt="danibachar" width="50px"></a></span>
<span><a href="https://github.com/HuseyinVural"><img src="https://github.com/HuseyinVural.png" alt="HuseyinVural" width="50px"></a></span>

## Donation

If you like this project or has been helpful to you, you can buy me a cup of coffe :)
Appreciate it!

[![paypal](https://github.com/josejuanqm/VersaPlayer/blob/master/RepoAssets/Artboard.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KGX5UDWNHBRNY)

## License

VersaPlayer is available under the MIT license. See the LICENSE file for more info.
