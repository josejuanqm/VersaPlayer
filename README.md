[![CI Status](https://img.shields.io/travis/jose.juan.qm@gmail.com/VersaPlayer.svg?style=flat)](https://travis-ci.org/jose.juan.qm@gmail.com/VersaPlayer)
[![Version](https://img.shields.io/cocoapods/v/VersaPlayer.svg?style=flat)](https://cocoapods.org/pods/VersaPlayer)
[![License](https://img.shields.io/cocoapods/l/VersaPlayer.svg?style=flat)](https://cocoapods.org/pods/VersaPlayer)
[![Platform](https://img.shields.io/cocoapods/p/VersaPlayer.svg?style=flat)](https://cocoapods.org/pods/VersaPlayer)

<div>
  <p align="center">
    <img src="https://github.com/josejuanqm/VersaPlayer/blob/master/Image.png" />
  </p>
</div>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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

## Usage

### Basic Usage

VersaPlayer aims to be simple to use but also flexible, to start using VersaPlayer first create a view programatically or via storyboard. Then add this few lines of code to start playing your video.

<div>
  <p align="center">
    <img src="https://github.com/josejuanqm/VersaPlayer/blob/master/simple_example.png" />
  </p>
</div>

The VersaPlayer Class comes with packed with:

#### Attributes

| Attribute | Name | Description |
| --------- | -------------- | -------- |
| player | Player | VPlayer class, which is a AVPlayer Implementation |
| renderingView | Rendering View | VPlayerRenderingView class instance |
| playbackDelegate | Playback Delegate | VersaPlayerPlaybackDelegate instance to be used as a playback delegate |
| pipController | PIP controller | PIP controller instance |
| autoplay | Auto Play | Used to tell AutoPlay enabled or disabled when adding a VPlayerItem to VersaPlayer |
| isPlaying | Is Playing | Used to know whether the player is playing or not |
| isSeeking | Is Seeking | Used to know whether the player is seeking or not |
| isFullscrenModeEnabled | Is Fullscreen Enabled | Used to know whether fullscreen mode is enabled |
| isPipModeEnabled | Is PIP Enabled | Used to know whether pip is enabled |

#### Methods

| Attribute | Action | Description |
| ------------- | -------------- | -------- |
| addExtension(extension ext: VersaPlayerExtension, with name: String) | Add Extension | Used to add a VersaPlayerExtension |
| getExtension(with name: String) | Get Extension | Used to get a previously added VersaPlayerExtension |
| setNativePip(enabled: Bool) | Set PIP Enabled | Set PIP enabled or disabled |
| setFullscreen(enabled: Bool) | Set Fullscreen Enabled | Set Fullscreen enabled or disabled |
| set(item: VPlayerItem?) | Set Item | Set VPlayerItem which is an implementation of AVPlayerItem |
| play() | Play | Used to set players rate to 1 |
| pause() | Pause | Uset to set players rate to 0 |
| togglePlayback() | Toggle Playback | Toggles the playback rate from 1 to 0 and from 0 to 1 |

### Adding Controls

To add controls for your player use the VersaPlayerControls class, which comes packed with outlets to control your player, you can also add as many as you like by making a custom implementation.

<div>
  <p align="center">
    <img src="https://github.com/josejuanqm/VersaPlayer/blob/master/controls_example.png" />
  </p>
</div>

The VersaPlayerControls Class comes with:

### Outlets

| Action | Description |
| -------------- | -------- |
| Play/Pause | Used to toggle player's playback |
| Rewind | Rewind playback |
| Forward | Fast forward playback |
| Skip Forward | Skip (n) seconds ahead (this can be configured from your controls "skipSize" parameter) |
| Skip Backward | Skip (n) seconds before (this can be configured from your controls "skipSize" parameter) |
| Fullscreen | Handles fullscreen presentation, this can also be handled manually |
| PIP | Enables PIP on supported devices, check whether to show this button by using AVFoundation |
| Seekbar | Enables Seeking through your content by using a UISlider |
| Current Time Label | Use this to show where is the playback currently at |
| Total Time Label | Use this to show how much the playback last |
| Buffering View | This view is shown when the player's item is buffering |

#### Attributes

| Attribute | Name | Description |
| --------- | -------------- | -------- |
| handler | Handler | VersaPlayer instance being controlled |
| behaviour | Behaviour | VersaPlayerControlsBehaviour instance controlling the VersaPlayerControlsCoordinator |
| controlsCoordinator | Controls Coordinator | VersaPlayerControlsCoordinator instance |

## Author

Jose Quintero - jose.juan.qm@gmail.com

## License

VersaPlayer is available under the MIT license. See the LICENSE file for more info.
