import UIKit
import SpriteKit
import AVFoundation // Import manualy.

// Important fix is in line 49.

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {
    
    // Create music player.
    var backgroundMusicPlayer:AVAudioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // Custom function.
    override func viewWillLayoutSubviews() {
        var bigMusicUrl:NSURL = NSBundle.mainBundle().URLForResource("bgmusic", withExtension: "mp3")!
        backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: bigMusicUrl, error: nil)
        
        // Create infinite loop of our music player.
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
        
        // Create our view.
        var skView:SKView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        // This line is changed from the one in the youtube tutorial.
        var scene = GameScene(size:skView.bounds.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        skView.presentScene(scene)
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
