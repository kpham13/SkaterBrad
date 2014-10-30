//
//  GameScene.swift
//  SkaterBrad
//
//  Created by Kevin Pham on 10/27/14.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero = SKSpriteNode()
    var road = SKSpriteNode()
    // Factor to set entry X position for hero
    let heroPositionX : CGFloat = 0.2
    
    // Background Movement [Tina]
    var backgroundSpeed : CGFloat = 1.0
    var roadSpeed : CGFloat = 3.0
    var roadSize : CGSize?
    
    // Score [Kevin]
    let scoreText = SKLabelNode(fontNamed: "Chalkduster")
    var score = 0
    
    // Jump Properties [Tuan/Vincent]
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false
    
    // Coin spritenode [Tuan]
    let coin = SKSpriteNode(imageNamed: "taco.gif")
    
    // Duck Properties
    var duckMode = false
    
    // Node Categories [Tuan/Vincent]
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2
    let obstacleCategory = 0x1 << 3
    let scoreCategory = 0x1 << 4
    let coinCategory = 0x1 << 5
    let contactCategory = 0x1 << 6
    
    // Texture Variables [Tina]
    var bradJumpTexture = SKTexture(imageNamed: "jump.jpg")
    var bradTexture = SKTexture(imageNamed: "normal.jpg")
    var bradDuckTexture = SKTexture(imageNamed: "duck.jpg")
    var bradJumpDownTexture = SKTexture(imageNamed: "jump2.jpg")
    
    // Screen Buttons [Sam]
    var playButton = SKSpriteNode(imageNamed: "playNow.png")
    var menuButton = SKSpriteNode(imageNamed: "menu.png")
    var backgroundMusicPlayer : AVAudioPlayer!
    
    override func didMoveToView(view: SKView) {
        self.registerAppTransitionObservers()
        self.playBackgroundMusic("bgMusic.mp3")
        
        self.createPlayButton()

        // Swipe Recognizer Setup [Tuan/Vincent]
        var swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUpAction:")
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUpRecognizer)
        
        var swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDownAction:")
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDownRecognizer)
        
        // self.addChild(obst2)
        
        // Physics - Setting Gravity to Game World
        self.physicsWorld.gravity = CGVectorMake(0.0, -9.8)
        self.physicsWorld.contactDelegate = self
        
        // City Background [Tina]
        
        for var index = 0; index < 2; ++index {
            let bg = SKSpriteNode(imageNamed: "bg\(index).jpg")
            bg.anchorPoint = CGPointZero
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 110)
            bg.name = "background"
            self.addChild(bg)
        }
        
        // Roads [Tina]
        for var index = 0; index < 2; ++index {
            self.road = SKSpriteNode(imageNamed: "road.jpg")
            self.road.anchorPoint = CGPointZero
            self.road.position = CGPoint(x: index * Int(self.road.size.width), y: 0)
            self.road.name = "road"
            self.roadSize = road.size
            // println(roadSize)
            self.addChild(self.road)
        }
        
        // Hero [Kevin/Tina]
        self.bradTexture.filteringMode = SKTextureFilteringMode.Nearest
        self.bradJumpTexture.filteringMode = SKTextureFilteringMode.Nearest
        self.bradDuckTexture.filteringMode = SKTextureFilteringMode.Nearest
        self.bradJumpDownTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        self.hero.name = "Brad"
        self.hero = SKSpriteNode(texture: bradTexture)
        self.hero.setScale(2.0)
        self.hero.position = CGPoint(x: self.frame.size.width * self.heroPositionX, y: self.frame.size.height * 0.5) // Change y to ground level
        self.hero.anchorPoint = CGPointZero
        
        // Physics Body Around Hero
        self.hero.physicsBody = SKPhysicsBody(rectangleOfSize: hero.size, center: CGPointMake(hero.frame.width / 2, hero.frame.height / 2))
        self.hero.physicsBody?.dynamic = true
        self.hero.physicsBody?.allowsRotation = false
        self.hero.physicsBody?.categoryBitMask = UInt32(self.heroCategory)
        self.hero.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.groundCategory) | UInt32(self.obstacleCategory)
        self.addChild(hero)
        
        // Ground [Kevin/Tina]
        var ground = SKShapeNode(rectOfSize: CGSize(width: 400, height: self.roadSize!.height))
        ground.name = "Ground"
        ground.hidden = true
        //ground.position = CGPoint(x: 0, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: self.roadSize!, center: CGPoint(x: self.roadSize!.width * 0.5, y: self.roadSize!.height * 0.5))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = UInt32(self.groundCategory)
        self.addChild(ground)
        
        // Game Score [Kevin]
        self.scoreText.text = "0"
        self.scoreText.fontSize = 42
        self.scoreText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.scoreText.zPosition = 100
        self.addChild(self.scoreText)
    }
    
    override func update(currentTime: CFTimeInterval) {
        // Lock Hero's X Position [Tina]
        self.hero.position.x = self.frame.size.width * self.heroPositionX
        
        // Moving Background [Kevin/Tina]
        self.enumerateChildNodesWithName("background", usingBlock: { (node, stop) -> Void in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPoint(x: bg.position.x-self.backgroundSpeed, y: bg.position.y)
                
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x+bg.size.width * 2, y: bg.position.y)
                }
            }
        })
        
        if self.hero.position.x <= 0 {
            println("Offscreen")
        }
        
        // Moving Road [Kevin/Tina, updated by Vincent]
        self.enumerateChildNodesWithName("road", usingBlock: { (node, stop) -> Void in
            if let road = node as? SKSpriteNode {
                road.position = CGPoint(x: road.position.x-self.roadSpeed, y: road.position.y)
                if road.position.x <= -road.size.width {
                    road.position = CGPoint(x: road.position.x+road.size.width * 2, y: road.position.y)
                }
                
                self.currentTime = currentTime
                self.deltaTime = self.currentTime - self.previousTime
                self.previousTime = currentTime
                self.jumpTime = self.jumpTime + self.deltaTime
            }
        })
        
        // Moving Obstacles [Brian/Kori, updated by Kevin]
        self.enumerateChildNodesWithName("vertical", usingBlock: { (node, stop) -> Void in
            if let vertical = node as SKNode? {
                vertical.position = CGPoint(x: vertical.position.x-self.roadSpeed, y: vertical.position.y)
                if vertical.position.x <= -self.frame.size.width * 3 {
                    vertical.removeFromParent()
                }
            }
        })
        
        self.enumerateChildNodesWithName("coin", usingBlock: { (node, stop) -> Void in
            if let coin = node as? SKSpriteNode {
                coin.position = CGPoint(x: coin.position.x-self.roadSpeed, y: coin.position.y)
                if coin.position.x < 0 {
                    coin.removeFromParent()
                }
            }
        })
        
        self.currentTime = currentTime
        self.deltaTime = self.currentTime - self.previousTime
        self.previousTime = currentTime
        self.jumpTime = self.jumpTime + self.deltaTime
        
        if self.jumpTime >= 0.5 && self.jumpMode == true {
            self.hero.texture = self.bradJumpDownTexture
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        var location = touch.locationInNode(self)
        
        if self.nodeAtPoint(location) == self.playButton {
            self.runAction(SKAction.runBlock({ () -> Void in
                self.playButton.removeFromParent()
                self.playGame()
            }))
        }
        
        if self.nodeAtPoint(location) == self.menuButton {
            self.runAction(SKAction.runBlock({ () -> Void in
                self.menuButton.removeFromParent()
                self.restartGame()
            }))
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask {
        case UInt32(self.heroCategory) | UInt32(self.groundCategory):
            println("Hero hit Ground")
            self.jumpNumber = 0
            if self.hero.texture != bradDuckTexture {
                self.hero.texture = bradTexture
            }
            self.jumpMode = false
        case UInt32(self.heroCategory) | UInt32(self.obstacleCategory):
            println("Hero hit obstacle")
            self.jumpNumber = 0
            if self.hero.texture != bradDuckTexture {
                self.hero.texture = bradTexture
            }
            self.jumpMode = false
        case UInt32(self.heroCategory) | UInt32(self.scoreCategory):
            println("Score!")
            self.score += 1
            self.scoreText.text = String(self.score)
        case UInt32(self.heroCategory) | UInt32(self.coinCategory):
            println("CHA CHING")
            self.coin.removeFromParent()
            runAction(SKAction.playSoundFileNamed("Twitterrocks.wav", waitForCompletion: false))
            self.score += 10
            self.scoreText.text = String(self.score)
        case UInt32(self.heroCategory) | UInt32(self.contactCategory):
            println("Hero hit contact node")
            self.showGameOver()
        default:
            println("Trash hit...obstacle?")
        }
    }

    // MARK: - HERO ACTIONS
    // [Tuan/Vincent]
    
    func swipeUpAction(swipe: UISwipeGestureRecognizer) {
        if self.duckMode == false {
            if self.jumpMode == false {
                self.jumpTime = 0.0
            }
            self.jumpMode = true
            //         Jump Limit Logic ------ Uncomment to use.
            if self.jumpNumber < 2 && self.jumpTime <= 0.5 {
                self.hero.physicsBody!.velocity = CGVectorMake(0, 0)
                self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 50))
                self.hero.texture = self.bradJumpTexture
                self.jumpNumber += 1
            }
        } else if self.duckMode == true {
            self.hero.yScale = 2.0
            self.hero.texture = bradTexture
            self.duckMode = false
        }
    }
    
    func swipeDownAction(swipe: UISwipeGestureRecognizer) {
        if duckMode == false && self.jumpMode == false{
            println("Swipe down")
            self.hero.yScale = 1.33
            self.hero.texture = bradDuckTexture
            self.duckMode = true
        }
    }
    
    // MARK: - OBSTACLES
    // [Brian/Kori]
    
    func spawnBench(){
        var randX: Float = Float(arc4random_uniform(300) + 1)
        //var anotherFloat: Float = Float(randX)
        
        // Vertical Nodes for Game Score [Kevin]
        let vertical = SKNode()
        vertical.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), 0)
        vertical.zPosition = 100
        vertical.name = "vertical"
        self.addChild(vertical)
        
        let bench = SKSpriteNode(imageNamed: "bench.gif")
        bench.size = CGSize(width: 105, height: 60)
        bench.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), (self.roadSize!.height + (bench.size.height / 2)))
        bench.zPosition = 110
        bench.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 105, height: 30))
        bench.physicsBody?.dynamic = false
         bench.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
         bench.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.obstacleCategory)
        bench.physicsBody?.node?.name = "bench"
        vertical.addChild(bench)
        
        let benchScoreContact = SKNode()
        //benchScoreContact.size = CGSize(width: 5, height: self.frame.size.height)
        //benchScoreContact.color = SKColor.redColor()
        benchScoreContact.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), CGRectGetMidY(self.frame))
        benchScoreContact.zPosition = 105
        benchScoreContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: self.frame.size.height))
        benchScoreContact.physicsBody?.dynamic = false
        benchScoreContact.physicsBody?.categoryBitMask = UInt32(self.scoreCategory)
        benchScoreContact.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.scoreCategory)
        benchScoreContact.physicsBody?.node?.name = "benchScoreContact"
        vertical.addChild(benchScoreContact)
    }
    
    func spawnTrashcan() {
        var randX: Float = Float(arc4random_uniform(500) + 100)
        //var anotherFloat: Float = Float(randX)
        
        // Vertical Nodes for Game Score [Kevin]
        let vertical = SKNode()
        vertical.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), 0)
        vertical.zPosition = 100
        vertical.name = "vertical"
        self.addChild(vertical)

        let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        trashCan.size = CGSize(width: 35, height: 40)
        trashCan.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), (self.roadSize!.height + (trashCan.size.height / 2)))
        trashCan.zPosition = 110
        trashCan.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 35, height: 40))
        trashCan.physicsBody?.dynamic = false
         trashCan.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
         trashCan.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.obstacleCategory)
        trashCan.physicsBody?.node?.name = "trashCan"
        vertical.addChild(trashCan)
        
        let trashScoreContact = SKNode()
        //trashScoreContact.size = CGSize(width: 5, height: self.frame.size.height)
        //trashScoreContact.color = SKColor.blueColor()
        trashScoreContact.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), CGRectGetMidY(self.frame))
        trashScoreContact.zPosition = 105
        trashScoreContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: self.frame.size.height))
        trashScoreContact.physicsBody?.dynamic = false
        trashScoreContact.physicsBody?.categoryBitMask = UInt32(self.scoreCategory)
        trashScoreContact.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.scoreCategory)
        trashScoreContact.physicsBody?.node?.name = "trashScoreContact"
        vertical.addChild(trashScoreContact)
    }
    
    func spawnCrane(){
        var randX = arc4random_uniform(300) + 100
        
        // Vertical Nodes for Game Score [Kevin]
        let vertical = SKNode()
        vertical.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), 0)
        vertical.zPosition = 100
        vertical.name = "vertical"
        self.addChild(vertical)
        
        let chain = SKSpriteNode(imageNamed: "chain.png")
        chain.size = CGSize(width: 10, height: 350)
        chain.anchorPoint = CGPointMake(0.5, 1.0)
        chain.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), CGRectGetMaxY(self.frame))
        chain.zPosition = 110
        vertical.addChild(chain)
        
        let craneHook = SKSpriteNode(imageNamed: "crane.gif")
        craneHook.size = CGSize(width: 100.0, height: 100.0)
        craneHook.anchorPoint = CGPointMake(0.5, 1.0)
        craneHook.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), CGRectGetMaxY(self.frame) - chain.size.height)
        craneHook.zPosition = 110
        craneHook.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 130, height: 165))
        craneHook.physicsBody?.dynamic = false
        craneHook.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        craneHook.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.obstacleCategory)
        vertical.addChild(craneHook)
        
        let craneScoreContact = SKNode()
        //craneScoreContact.size = CGSize(width: 5, height: self.frame.size.height)
        //craneScoreContact.color = SKColor.blueColor()
        craneScoreContact.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), CGRectGetMidY(self.frame))
        craneScoreContact.zPosition = 105
        craneScoreContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: self.frame.size.height))
        craneScoreContact.physicsBody?.dynamic = false
        craneScoreContact.physicsBody?.categoryBitMask = UInt32(self.scoreCategory)
        craneScoreContact.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.scoreCategory)
        craneScoreContact.physicsBody?.node?.name = "benchScoreContact"
        vertical.addChild(craneScoreContact)
    }
    
    // Spawn coin [Tuan]
    func spawnCoin() {
        var randX = arc4random_uniform(100)
        self.coin
        coin.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, 250)
        coin.size = CGSize(width: 30, height: 30)
        
        coin.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1 , height: 1))
        coin.physicsBody?.dynamic = false
        
        coin.physicsBody?.categoryBitMask = UInt32(self.coinCategory)
        coin.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.coinCategory)
        coin.zPosition = 12
        coin.physicsBody?.node?.name = "coin"
        coin.name = "coin"
        addChild(coin)
    }
    
    // MARK: - Menu Screens
    // [Sam]
    
    func playBackgroundMusic(filename: String) {
        let url = NSBundle.mainBundle().URLForResource(
            filename, withExtension: nil)
        if (url == nil) {
            println("Could not find file: \(filename)")
            return
        }
        
        var error: NSError? = nil
        backgroundMusicPlayer =
            AVAudioPlayer(contentsOfURL: url, error: &error)
        if backgroundMusicPlayer == nil {
            println("Could not create audio player: \(error!)")
            return
        }
        
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    }
    
    func createPlayButton() {
        playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 80)
        playButton.zPosition = 5
        self.addChild(self.playButton)
    }
    
    func createMenuButton() {
        menuButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 30 )
        menuButton.zPosition = 5
        
        self.addChild(self.menuButton)
    }
    
    func showGameOver() {
        backgroundMusicPlayer.stop()
        self.hero.physicsBody?.dynamic = false
        self.roadSpeed = 0
        self.backgroundSpeed = 0
        
        self.createMenuButton()
        
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Game Over"
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100 )
        addChild(label)
        
        let grayScreen = SKSpriteNode()
        grayScreen.size = CGSize(width: CGRectGetMaxX(self.frame), height: CGRectGetMaxY(self.frame))
        grayScreen.position = CGPointMake((CGRectGetMaxX(self.frame)/2),
            CGRectGetMaxY(self.frame)/2)
        grayScreen.color = SKColor.blackColor()
        grayScreen.alpha = 0.5
        
        //brad soundbite [Tuan]
        runAction(SKAction.playSoundFileNamed("Getitnexttime.wav", waitForCompletion: false))

        self.addChild(grayScreen)
    }
    
    func restartGame() {
        self.roadSpeed = 5.0
        self.backgroundSpeed = 1.0
        
        var scene = GameScene(size: self.size)
        let skView = self.view! as SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.size = skView.bounds.size
        skView.presentScene(scene)
    }
    
    func playGame() {
        // Obstacles Spawn, every 2 seconds [Brian/Kori]
        let spawnBench  = SKAction.runBlock({() in self.spawnBench()})
        let spawnTrashcan = SKAction.runBlock({() in self.spawnTrashcan()})
        // Coin [Tuan]
        let spawnCoin = SKAction.runBlock({() in self.spawnCoin()})
        
        let craneHook = SKAction.runBlock({() in self.spawnCrane()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawnCoin, delay, spawnBench,delay,spawnTrashcan,spawnTrashcan,delay, delay, craneHook, spawnTrashcan])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    func registerAppTransitionObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name:UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name:UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func applicationWillResignActive() {
        backgroundMusicPlayer.stop()
        self.scene?.paused = true
    }
    
    func applicationDidEnterBackground() {
        backgroundMusicPlayer.stop()
        self.scene?.paused = true
    }
    
    func applicationWillEnterForeground() {
        self.scene?.paused = false
        backgroundMusicPlayer.play()
    }
    
}
