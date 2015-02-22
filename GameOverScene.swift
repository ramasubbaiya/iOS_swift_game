import UIKit
import SpriteKit

// Some minor changes in this file. But one veryi important though. It starts at line 41.

class GameOverScene: SKScene {
    init(size:CGSize, won:Bool){
        super.init(size: size)
        
        // Set background to black color.
        self.backgroundColor = SKColor.blackColor()
        
        // Create message.
        var message:String
        
        if won {
            message = "You win!"
        } else {
            message = "Game Over"
        }
        
        // Create label.
        var label = SKLabelNode(fontNamed: "DamascusBold")
        label.text = message // Add text to label.
        label.fontColor = SKColor.whiteColor()
        label.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5)
        
        // Add label to screen.
        self.addChild(label)
        
        // Because player lost, lets run this squence of events.
        self.runAction(SKAction.sequence([SKAction.waitForDuration(3.0), SKAction.runBlock({
            var transition = SKTransition.flipHorizontalWithDuration(0.5)
            var scene = GameScene(size: self.size)
            self.view?.presentScene(scene, transition: transition)
        })]))
    }

    // You have to add this into your file, otherwise it will not build.
    // Xcode will usually suggest to inject this code automaticly.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
