// https://github.com/Quick/Quick

import Quick
import Nimble
import VersaPlayer

class TableOfContentsSpec: QuickSpec {
    
    var player: VersaPlayer = VersaPlayer(frame: .zero)
    var container: UIView = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
    
    override func spec() {
        describe("VersaPlayer set item") {
            it("item can be set") {
                if let url = URL.init(string: "http://rmcdn.2mdn.net/Demo/html5/output.mp4") {
                    let item = VPlayerItem(url: url)
                    self.player.set(item: item)
                    expect(self.player.player.currentItem).notTo(beNil())
                }
            }
            
            it("can be played") {
                self.player.play()
                expect(self.player.isPlaying) == true
            }
            
            it("can be paused") {
                if self.player.isPlaying {
                    self.player.pause()
                    expect(self.player.isPlaying).notTo(be(true))
                }
            }
        }
    }
}
