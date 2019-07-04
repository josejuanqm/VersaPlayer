[![CI Status](https://img.shields.io/travis/jose.juan.qm@gmail.com/VersaPlayer.svg?style=flat)](https://travis-ci.org/jose.juan.qm@gmail.com/VersaPlayer)
[![Version](https://img.shields.io/cocoapods/v/VersaPlayer.svg?style=flat)](https://cocoapods.org/pods/VersaPlayer)
[![License](https://img.shields.io/cocoapods/l/VersaPlayer.svg?style=flat)](https://cocoapods.org/pods/VersaPlayer)
[![Platform](https://img.shields.io/cocoapods/p/VersaPlayer.svg?style=flat)](https://cocoapods.org/pods/VersaPlayer)

### News
##### :tada: - Since 2.1.3 VersaPlayer now supports iOS, macOS, and tvOS

---

<div>
  <p align="center">
    <img src="https://github.com/josejuanqm/VersaPlayer/blob/master/Image.png" />
  </p>
</div>

<div>
  <ol>
    <li>
      <a href="#example">Example</a>
    </li>
    <li>
      <a href="#installation">Installation</a>
    </li>
    <li>
      <a href="#usage">Usage</a>
    </li>
    <ol>
      <li>
        <a href="#basic-usage">Basic Usage</a>
      </li>
      <li>
        <a href="#adding-controls">Adding Controls</a>
      </li>
      <li>
        <a href="#advanced-usage">Advanced Usage</a>
      </li>
      <ol>
        <li>
          <a href="#drm">Encrypted Content (Digital Rights Management)</a>
        </li>
        <li>
          <a href="#tracks">Track Selection</a>
        </li>
        <ol>
          <li>
            <a href="#audio-tracks">Audio Tracks</a>
          </li>
          <li>
            <a href="#video-tracks">Video Tracks</a>
          </li>
          <li>
            <a href="#caption-tracks">Caption Tracks</a>
          </li>
          <ol>
            <li>
              <a href="#caption-styling">Caption Styling</a>
            </li>
          </ol>
        </ol>
      </ol>
    </ol>
    <li>
      <a href="#extensions">Extensions</a>
    </li>
    <ol>
      <li>
        <a href="#extensions">Airplay Extension</a>
      </li>
      <li>
        <a href="#extensions">Ads Extension</a>
      </li>
      <li>
        <a href="#extensions">Overlay Content Extension</a>
      </li>
    </ol>
    <li>
      <a href="#documentation">Documentation</a>
    </li>
    <li>
      <a href="#contributors">Awesome People (Contributors)</a>
    </li>
    <li>
      <a href="#donation">Donation</a>
    </li>
  </ol>
</div>

## Community

If you have any doubts or need help with anything, head over to [Gitter](https://gitter.im/VersaPlayer/Lobby) and ask it there!

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<div>
  <p align="center">
    <img src="https://github.com/josejuanqm/VersaPlayer/blob/master/RepoAssets/iphone.png" />
  </p>
</div>

## Installation

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.
You can install it with the following command:

```bash
$ gem install cocoapods
```

VersaPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'VersaPlayer'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "josejuanqm/VersaPlayer" "3.0.0"
```

## Usage

### Basic Usage

VersaPlayer aims to be simple to use but also flexible, to start using VersaPlayer first create a view programatically or via storyboard. Then add this few lines of code to start playing your video.

```swift
    @IBOutlet weak var playerView: VersaPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL.init(string: "http://rmcdn.2mdn.net/Demo/html5/output.mp4") {
            let item = VersaPlayerItem(url: url)
            playerView.set(item: item)
        }
    }
```

### Adding Controls

To add controls for your player use the VersaPlayerControls class, which comes packed with outlets to control your player, you can also add as many as you like by making a custom implementation.

VersaPlayerControls class include the following outlets:

Outlet Name             | Type             |  Action
------------------------- | ------------------------- | -------------------------
playPauseButton | VersaStatefullButton | Toggle playback
fullscreenButton | VersaStatefullButton | Toggle fullscreen mode
pipButton | VersaStatefullButton | Toggle PIP mode in supported devices
rewindButton | VersaStatefullButton | Rewind playback
forwardButton | VersaStatefullButton | Fast forward playback
skipForwardButton | VersaStatefullButton | Skip forward the time specified in second at skipSize (found in VersaPlayerControls)
skipBackwardButton | VersaStatefullButton | Skip backward the time specified in second at skipSize (found in VersaPlayerControls)
seekbarSlider | VersaSeekbarSlider | Seek through playback
currentTimeLabel | VersaTimeLabel | Indicate the current time
totalTimeLabel | VersaTimeLabel | Indicate the total time
bufferingView | UIView | Shown when player is buffering

```swift
    @IBOutlet weak var playerView: VersaPlayerView!
    @IBOutlet weak var controls: VersaPlayerControls!

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.use(controls: controls)
        if let url = URL.init(string: "http://rmcdn.2mdn.net/Demo/html5/output.mp4") {
            let item = VersaPlayerItem(url: url)
            playerView.set(item: item)
        }
    }
```

### Advanced Usage

#### DRM

VersaPlayer also brings support for encrypted content, to make use of this funcionality you must implement VersaPlayerDecryptionDelegate and assign it to VersaPlayer's decryptionDelegate property.

To read more about this topic go to:

https://josejuanqm.github.io/Libraries-Documentation/VersaPlayerCore/Protocols/VersaPlayerDecryptionDelegate.html

#### Tracks

To make use of different media tracks, such as audio, video, or captioning, use VersaPlayerMediaTracks, found in VersaPlayer class.

to learn more about this properties go to:

https://josejuanqm.github.io/Libraries-Documentation/VersaPlayerCore/Classes/VersaPlayerMediaTrack.html

##### Audio Tracks

Audio tracks are specially helpfull when dealing with different languages, for example for a movie playback. 

To select an audio track simply fetch available tracks with VersaPlayer's audioTracks property.

```swift
    @IBOutlet weak var playerView: VersaPlayer!

    ...
    
    let tracks: [VersaPlayerMediaTrack] = playerView.player.currentItem?.audioTracks
    /// the name of the track
    let name = tracks.first?.name
    /// the language of the track
    let name = tracks.first?.language
    /// selecting the first one
    tracks.first?.select(for: playerView.player)
```

##### Video Tracks

Video tracks are most helpfull when dealing with different renditions or different streams per video quality. 

To select an video track simply follow the same principles as an audio track.

```swift
    @IBOutlet weak var playerView: VersaPlayer!

    ...
    
    let tracks: [VersaPlayerMediaTrack] = playerView.player.currentItem?.videoTracks
    /// the name of the track
    let name = tracks.first?.name
    /// selecting the first one
    tracks.first?.select(for: playerView.player)
```

##### Caption Tracks

Caption tracks are almost always helpfull. This can be used from a movie playback all the way to assitive content. 

To select an video track simply follow the same principles as video and audio tracks.

```swift
    @IBOutlet weak var playerView: VersaPlayer!

    ...
    
    let tracks: [VersaPlayerMediaTrack] = playerView.player.currentItem?.captionTracks
    /// the name of the track
    let name = tracks.first?.name
    /// the language of the track
    let name = tracks.first?.language
    /// selecting the first one
    tracks.first?.select(for: playerView.player)
```

###### Caption Styling

Caption styling are not usually managed by the user, but when necessary, captionStyling property from VersaPlayer comes in handy.

Explore all the available attributes that can be changed here:

https://josejuanqm.github.io/Libraries-Documentation/VersaPlayerCore/Classes/VersaPlayerCaptionStyling.html

## Extensions

Versa is aimed to be versatile, and that's why it comes with an extensions feature, that lets you customize any aspect of the player by inheriting from VersaPlayerExtension.

This class comes with a player attribute that points to the player instance from which is being used.
To add an extension use the add(extension ext:) method found in https://josejuanqm.github.io/Libraries-Documentation/VersaPlayerCore/Classes/VersaPlayer.html.

Here are some extensions for VersaPlayer that may be useful for you.

1. [AirPlay Extension](https://github.com/josejuanqm/VersaPlayerAirplayExtension)

2. [Ads Extension](https://github.com/josejuanqm/VersaPlayerAdsExtension)

3. [Overlay Content Extension](https://github.com/josejuanqm/VersaPlayerOverlayContentExtension)


## Documentation

Full documentation avilable https://josejuanqm.github.io/Libraries-Documentation/VersaPlayerCore/

## Author

Jose Quintero - jose.juan.qm@gmail.com

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
