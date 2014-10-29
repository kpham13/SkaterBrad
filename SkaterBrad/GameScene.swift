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
    
    // Duck Properties
    var duckMode = false
    
    // Node Categories [Tuan/Vincent]
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2
    let obstacleCategory = 0x1 << 3
    
    // Texture Variables [Tina]
    var bradJumpTexture = SKTexture(imageNamed: "test.jpg")
    var bradTexture = SKTexture(imageNamed: "hero.jpg")
    var bradDuckTexture = SKTexture(imageNamed: "test2.jpg")
    
    
  
    // Screen Buttons [Sam]
    var playButton = SKSpriteNode(imageNamed: "playnow.png")
    var menuButton = SKSpriteNode(imageNamed: "menu.png")
    var backgroundMusicPlayer : AVAudioPlayer!
    
    override func didMoveToView(view: SKView) {
        self.registerAppTransitionObservers() 
        self.playBackgroundMusic("bgMusic.mp3")
        
        self.createPlayButton()
      
        // Texture Variables

        //let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        //let craneHook = SKSpriteNode(imageNamed: "crane.gif")
        //brian notes
        let block1 = SKSpriteNode(imageNamed: "block1")
      
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
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 0)
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
        var bradTexture = SKTexture(imageNamed: "hero.jpg") // Change 90x90 image
        var bradJumpTexture = SKTexture(imageNamed: "")
        var bradDuckTexture = SKTexture(imageNamed: "")

        bradTexture.filteringMode = SKTextureFilteringMode.Nearest
        bradJumpTexture.filteringMode = SKTextureFilteringMode.Nearest
        bradDuckTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        hero.name = "Brad"
        hero = SKSpriteNode(texture: bradTexture)
        hero.setScale(0.5)
        hero.position = CGPoint(x: self.frame.size.width * self.heroPositionX, y: self.frame.size.height * 0.5) // Change y to ground level
        hero.anchorPoint = CGPointZero
        
        // Physics Body Around Hero
        hero.physicsBody = SKPhysicsBody(rectangleOfSize: hero.size, center: CGPointMake(hero.frame.width / 2, hero.frame.height / 2))
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = UInt32(self.heroCategory)
        hero.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.groundCategory) | UInt32(self.obstacleCategory)
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

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        var location = touch.locationInNode(self)
        
        if self.nodeAtPoint(location) == self.playButton {
            self.runAction(SKAction.runBlock({ () -> Void in
                self.playGame()
            }))
        }
        
        if self.nodeAtPoint(location) == self.menuButton {
            self.runAction(SKAction.runBlock({ () -> Void in
                self.restartGame()
            }))
        }
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
        playButton.removeFromParent()

        // Obstacles Spawn, every 2 seconds [Brian/Kori]
        let spawnBench  = SKAction.runBlock({() in self.spawnBench()})
        let spawnTrashcan = SKAction.runBlock({() in self.spawnTrashcan()})
        let craneHook = SKAction.runBlock({() in self.spawnCrane()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawnBench,delay,spawnTrashcan,spawnTrashcan,delay, delay, craneHook, spawnTrashcan])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)

    }
    
    override func update(currentTime: CFTimeInterval) {
        
        // lock hero's x position
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
                
                
                if self.jumpMode == true {
                    self.currentTime = currentTime
                    self.deltaTime = self.currentTime - self.previousTime
                    self.previousTime = currentTime
                    self.jumpTime = self.jumpTime + self.deltaTime
                }
            }
        })
        
        // Moving Obstacles [Brian/Kori]
        self.enumerateChildNodesWithName("trashCan", usingBlock: { (node, stop) -> Void in
            if let trash = node as? SKSpriteNode {
                trash.position = CGPoint(x: trash.position.x-self.roadSpeed, y: trash.position.y)
                if trash.position.x < 0 {
                    trash.removeFromParent()
                }
            }
        })
      
        self.enumerateChildNodesWithName("bench", usingBlock: { (node, stop) -> Void in
            if let craneHook = node as? SKSpriteNode {
                craneHook.position = CGPoint(x: craneHook.position.x - (self.roadSpeed), y: craneHook.position.y)
                if craneHook.position.x < 0 {
                    craneHook.removeFromParent()
                }
            }
        })

        self.enumerateChildNodesWithName("craneHook", usingBlock: { (node, stop) -> Void in
            if let craneHook = node as? SKSpriteNode {
                craneHook.position = CGPoint(x: craneHook.position.x - (self.roadSpeed/2), y: craneHook.position.y)
                if craneHook.position.x < 0 {
                    craneHook.removeFromParent()
                }
            }
        })
        
    }
    
    // MARK: - HERO ACTIONS
    // [Tuan/Vincent]
    
    func swipeUpAction(swipe: UISwipeGestureRecognizer) {
        if self.duckMode == false {
            self.jumpMode = true
            self.jumpTime = 0.0
            println(self.jumpNumber)
            println(self.jumpTime)
            println(self.deltaTime)
            
            
            //         Jump Limit Logic ------ Uncomment to use.
            if self.jumpNumber < 2 && self.jumpTime <= 0.5 {
                self.hero.physicsBody!.velocity = CGVectorMake(0, 0)
                self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 35))
                self.hero.texture = self.bradDuckTexture
                self.jumpNumber += 1
            }
        } else if self.duckMode == true {
            let originalHeight = hero.frame.height * 2
            let stand = SKAction.resizeToHeight(originalHeight, duration: 0.5)
            self.hero.runAction(stand)
            println(hero.physicsBody!.area)
            self.duckMode = false
        }
    }
    
    func swipeDownAction(swipe: UISwipeGestureRecognizer) {
        if duckMode == false {
            println("Swipe down")
            
            let originalHeight = hero.frame.height
            let duckHeight = originalHeight / 2
            
            let duck = SKAction.resizeToHeight(duckHeight, duration: 0.5)
            
            self.hero.runAction(duck)
            println(hero.physicsBody!.area)
            self.duckMode = true
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        println("Contact occured")
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask {
        case UInt32(self.heroCategory) | UInt32(self.groundCategory):
            println("Hero hit Ground")
            self.jumpNumber = 0
        case UInt32(self.heroCategory) | UInt32(self.obstacleCategory):
            println("Hero hit obstacle")
            self.showGameOver()
//test
            
        default:
            println("Trash hit...obstacle?")
        }
    }
    
    // MARK: - OBSTACLES
    // [Brian/Kori]
    
    func spawnBench(){
        var randX: Float = Float(arc4random_uniform(300) + 1)
        //var anotherFloat: Float = Float(randX)
        
        let bench = SKSpriteNode(imageNamed: "bench")
        
        bench.position = CGPointMake(CGRectGetMaxX(self.frame), 75)
        bench.size = CGSize(width: 105, height: 30)
        bench.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 105, height: 30))
        bench.physicsBody?.dynamic = false
        bench.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        bench.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.obstacleCategory)
        bench.physicsBody?.node?.name = "bench"
        bench.zPosition = 0
        bench.name = "bench"
        self.addChild(bench)
    }
    
    func spawnCrane(){
        var randX = arc4random_uniform(300) + 100
        let craneHook = SKSpriteNode(imageNamed: "crane.gif")
        
        craneHook.anchorPoint = CGPointMake(1.0, 1.0)
        craneHook.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX),
            CGRectGetMaxY(self.frame))
        craneHook.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 60, height: 100))
        craneHook.physicsBody?.dynamic = false
        craneHook.size = CGSize(width: 60.0, height: 100.0)
        craneHook.name = "craneHook"
        self.addChild(craneHook)
    }
    
    
    func spawnTrashcan(){
        var randX: Float = Float(arc4random_uniform(500) + 100)
        //var anotherFloat: Float = Float(randX)
        
        //    let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        
        trashCan.position = CGPointMake(CGRectGetMaxX(self.frame) + CGFloat(randX), 75)
        trashCan.size = CGSize(width: 35, height: 40)
        trashCan.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 35, height: 40))
        trashCan.physicsBody?.dynamic = false
        trashCan.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        trashCan.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.obstacleCategory)
        trashCan.physicsBody?.node?.name = "trashCan"
        trashCan.zPosition = 12
        trashCan.name = "trashCan"
        addChild(trashCan)
    }
  
}

