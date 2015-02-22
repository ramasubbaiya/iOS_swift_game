import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Bitmasks.
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    // Create som custom properties.
    var player:SKSpriteNode = SKSpriteNode()
    var lastYielTimeInterval:NSTimeInterval = NSTimeInterval()
    var lastUpdateTimerInterval:NSTimeInterval = NSTimeInterval()
    
    // Create score label.
    // Added by Boris Filipović.
    var scoreLabel:SKLabelNode = SKLabelNode()
    
    var alienDestroyed = 0
    
    // Write custom init method.
    override init(size: CGSize) {
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPointMake(self.frame.size.width * 0.5, player.size.height * 0.5 + 20)
        
        // Add player to view.
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        // Add label to the view.
        // Added by Boris Filipović.
        scoreLabel.position = CGPointMake(15, 15)
        self.addChild(scoreLabel)
        
        // Initial Score label will be 0.
        // Added by Boris Filipović.
        scoreLabelUpdate(0)
    }
    // Added by Boris Filipović.
    // This lines of code Xcode will inject automaticlly.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
    }
    
    func addAlien(){
        var alien = SKSpriteNode(imageNamed: "alien")
        
        // Random position for alien. 
        let positionX = CGFloat(arc4random() % UInt32(self.frame.width))
        
        alien.position = CGPointMake(positionX, self.frame.height - 20)
        alien.physicsBody = SKPhysicsBody(rectangleOfSize: alien.size)
        
        // // Added by Boris Filipović.
        // You have to put optionals here otherwise compiler will throw error.
        alien.physicsBody?.dynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        self.addChild(alien) // Display it on the screen.
        
        // Set constanst for animation.
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        let duration = arc4random() % UInt32(rangeDuration) + UInt32(minDuration)
        
        // Create action.
        var actionArray:NSMutableArray = NSMutableArray()
        actionArray.addObject(SKAction.moveTo(CGPointMake(positionX, -alien.size.height), duration: NSTimeInterval(duration)))
        
        // Game over action.
        // Slightly different syntax here. Look for optional(?) character in sel.view and "->Void" in block syntax.
        actionArray.addObject(SKAction.runBlock({ () -> Void in
            var transition = SKTransition.flipHorizontalWithDuration(0.5)
            var gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: transition)
        }))

        // Remove aliens ship from the screene.
        actionArray.addObject(SKAction.removeFromParent())
        
        // Run action.
        alien.runAction(SKAction.sequence(actionArray))
    }
    
    // Update.
    func updateWithTimeSinceLastUpdate(timeSinceLastUpdate:CFTimeInterval){
        lastYielTimeInterval += timeSinceLastUpdate
        if(lastYielTimeInterval > 1){
            lastYielTimeInterval = 0
            addAlien()
        }
    }
    
    // write score to the label.
    // Extra code added by Boris Filipović.
    func scoreLabelUpdate(newscore:Int){
        scoreLabel.text = "\(newscore)" // Add int into string. In objective-c you would use stringWithFormat for that.
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.runAction(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        var touch = touches.anyObject() as UITouch
        var location = touch.locationInNode(self) // Location in self.
        
        // Initialize location of torpedo.
        var torpedo = SKSpriteNode(imageNamed: "torpedo") // Create torpedo SKSpriteNode.
        torpedo.position = player.position  // Give it some position.
        torpedo.physicsBody = SKPhysicsBody(circleOfRadius: torpedo.size.width * 0.5)
        
        // Again, here are added optional(?) characters.
        torpedo.physicsBody?.dynamic = true
        torpedo.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedo.physicsBody?.contactTestBitMask = alienCategory
        torpedo.physicsBody?.collisionBitMask = 0
        torpedo.physicsBody?.usesPreciseCollisionDetection = true
        
        var offset = vecSub(location, b: torpedo.position)
        
        if offset.y < 0 {
            return
        }
        
        // Put torpedo on screen.
        self.addChild(torpedo)
        
        // Direction of torpedo.
        var direction = vecNormalized(offset)
        
        var shotLength = vecMult(direction, b: 1000)
        
        var finalDestination = vecAdd(shotLength, b: torpedo.position)
        
        let velocity = 568/1
        let moveDuration = Float(self.size.width) / Float(velocity)
        
        var actionArray = NSMutableArray()
        actionArray.addObject(SKAction.moveTo(finalDestination, duration: NSTimeInterval(moveDuration)))
        actionArray.addObject(SKAction.removeFromParent())
        
        torpedo.runAction(SKAction.sequence(actionArray))
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody // Torpedo.
        var secondBody:SKPhysicsBody // Alien.
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & photonTorpedoCategory) != 0) && ((secondBody.categoryBitMask & alienCategory) != 0){
            torpedoDidCollideWithAlien(firstBody.node as SKSpriteNode, alien: secondBody.node as SKSpriteNode)
        }
    }
    
    func torpedoDidCollideWithAlien(torpedo:SKSpriteNode, alien:SKSpriteNode){
        // When hit occures.
        // println("HIT")
        torpedo.removeFromParent() // Remove torpedo from view.
        alien.removeFromParent() // Remove alien from view.
        
        alienDestroyed++
        
        // Update score label.
        // Custom code for score label.
        scoreLabelUpdate(alienDestroyed)
        
        if alienDestroyed > 10 {
            var transition = SKTransition.flipHorizontalWithDuration(0.5)
            var gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var timeSinceLastUpdate = currentTime - lastUpdateTimerInterval
        lastUpdateTimerInterval = currentTime
        
        if timeSinceLastUpdate > 1 {
            timeSinceLastUpdate = 1/60
            lastUpdateTimerInterval = currentTime
        }
        
        updateWithTimeSinceLastUpdate(timeSinceLastUpdate)
    }
    
    // Vector manipulation functions.
    // Here some big changes are made.
    func vecAdd(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x + b.x, a.y + b.y)
    }
    
    func vecSub(a:CGPoint, b:CGPoint)->CGPoint{
        return CGPointMake(a.x - b.x, a.y - b.y)
    }
    
    func vecMult(a:CGPoint, b:CGFloat)->CGPoint{
        return CGPointMake(a.x * b, a.y * b)
    }
    
    func vecLength(a:CGPoint)->CGFloat{
        return sqrt(a.x * a.x + a.y * a.y)
    }
    
    func vecNormalized(a:CGPoint)->CGPoint{
        var length = vecLength(a)
        return CGPointMake( a.x / length, a.y / length)
    }
}
