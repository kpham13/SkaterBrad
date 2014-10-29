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

    // Jump Properties [Tuan/Vincent]
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false
    
    // Speed Time
    var speedTime = 0.0
    var speedMode = false

    // Background Movement [Tina]
    var backgroundSpeed : CGFloat = 1.0
    var roadSpeed : CGFloat = 5.0
    var roadSize : CGSize?
    
    // Node Categories [Tuan/Vincent]
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2
    let obstacleCategory = 0x1 << 3
  
    // Screen Buttons [Sam]
    var playButton = SKSpriteNode(imageNamed: "playnow.png")
    var menuButton = SKSpriteNode(imageNamed: "menu.png")
    var backgroundMusicPlayer : AVAudioPlayer!
    
    override func didMoveToView(view: SKView) {
        self.registerAppTransitionObservers() 
        self.playBackgroundMusic("bgMusic.mp3")
        
        self.createPlayButton()
      
        // Texture Variables
        let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        let craneHook = SKSpriteNode(imageNamed: "crane.gif")
        var bradJumpTexture = SKTexture(imageNamed: "")
        var bradDuckTexture = SKTexture(imageNamed: "")

        // Swipe Recognizer Setup [Tuan/Vincent]
        var swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUpAction:")
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUpRecognizer)
        
        //Swipe Left Recognizer
        var swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeftAction:")
        swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view?.addGestureRecognizer(swipeLeftRecognizer)
        
        // Physics - setting gravity to game world

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
            let road = SKSpriteNode(imageNamed: "road.jpg")
            road.anchorPoint = CGPointZero
            road.position = CGPoint(x: index * Int(road.size.width), y: 0)
            road.name = "road"
            self.roadSize = road.size
            self.addChild(road)
        }
        
        // Hero [Kevin/Tina]
        var bradTexture = SKTexture(imageNamed: "hero.jpg") // Change 90x90 image
        bradTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // Hero Jumping Texture [Tina]
        bradJumpTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // Hero Ducking Texture [Tina]
        bradDuckTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        hero.name = "Brad"
        hero = SKSpriteNode(texture: bradTexture)
        hero.setScale(0.5)
        hero.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.5) // Change y to ground level
        
        // Physics Body Around Hero
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.height / 2)

        // hero.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: hero.size.width, height: hero.size.height))

        // hero.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize) // look at later [Vincent]
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = UInt32(self.heroCategory)
        hero.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.groundCategory) | UInt32(self.obstacleCategory)
        self.addChild(hero)
        
        // Ground [Kevin/Tina]
        var ground = SKShapeNode(rectOfSize: CGSize(width: 400, height: self.roadSize!.height))
        ground.name = "Ground"
        ground.hidden = true
        ground.position = CGPoint(x: 0, y: self.roadSize!.height * 0.5)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: self.roadSize!)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = UInt32(self.groundCategory)

        //println(self.frame.size.width)
        //println(groundTexture.size().height * 2)
        
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

        //Spawns a Trash Can Every 2 Seconds [Brian/Kori]
        let spawn  = SKAction.runBlock({() in self.spawnObstacles()})
        let delay = SKAction.waitForDuration(NSTimeInterval(1.5))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    func swipeAction(swipe: UISwipeGestureRecognizer) {
        self.jumpMode = true
        self.jumpTime = 0.0
        println(self.jumpNumber)
        println(self.jumpTime)
        println(self.deltaTime)
        
        // Jump Limit Logic ------ Uncomment to use.
//        if self.jumpNumber < 2 && self.jumpTime <= 0.5 {
            self.hero.physicsBody!.velocity = CGVectorMake(0, 0)
            self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 60))
            self.jumpNumber += 1
//        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
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
        
        self.enumerateChildNodesWithName("road", usingBlock: { (node, stop) -> Void in
            if let road = node as? SKSpriteNode {
                road.position = CGPoint(x: road.position.x-self.roadSpeed, y: road.position.y)
                
                if road.position.x <= -road.size.width {
                    road.position = CGPoint(x: road.position.x+road.size.width * 2, y: road.position.y)
                }
            }
        })
      
        //kori and brian
        self.enumerateChildNodesWithName("trashCan", usingBlock: { (node, stop) -> Void in
            if let trash = node as? SKSpriteNode {
                trash.position = CGPoint(x: trash.position.x-self.roadSpeed, y: trash.position.y)
                
                if trash.position.x < 0 {
                    trash.removeFromParent()
                }
          
                if self.jumpMode == true {
                    self.currentTime = currentTime
                    self.deltaTime = self.currentTime - self.previousTime
                    self.previousTime = currentTime
                    self.jumpTime = self.jumpTime + self.deltaTime
                }
            }
        })
    }
    
    // MARK: - HERO ACTIONS
    // [Tuan/Vincent]
    
    func swipeUpAction(swipe: UISwipeGestureRecognizer) {
        self.jumpMode = true
        self.jumpTime = 0.0
        println(self.jumpNumber)
        println(self.jumpTime)
        println(self.deltaTime)
        
        //         Jump Limit Logic ------ Uncomment to use.
        if self.jumpNumber < 2 && self.jumpTime <= 0.5 {
            self.hero.physicsBody!.velocity = CGVectorMake(0, 0)
            self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 35))
            self.jumpNumber += 1
        }
    }
    
    func swipeDownAction(swipe: UISwipeGestureRecognizer) {
        println("Swipe down")
        let wait = SKAction.waitForDuration(1.0)
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

            
        default:
            println("Trash hit...obstacle?")
        }
        
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            println("A > B")
//        }
//        else {
//            firstBody = contact.bodyB
////            secondBody = contact.bodyA
//        }
//        println(contact.bodyA.node!.name)
//        println(contact.bodyB.node!.name)
        
    }
    
    // MARK: - OBSTACLES
    // [Brian/Kori]
    
    func spawnObstacles(){
        
        let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        let craneHook = SKSpriteNode(imageNamed: "crane.gif")
        
        trashCan.position = CGPointMake(/*CGRectGetMinX(self.frame) +*/ self.frame.width, 75)
        trashCan.size = CGSize(width: 35, height: 40)
        trashCan.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 35, height: 40))
        trashCan.physicsBody?.dynamic = false
        trashCan.zPosition = 12
        trashCan.name = "trashCan"
        trashCan.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        self.addChild(trashCan)
        
        craneHook.anchorPoint = CGPointMake(1.0, 5.0)
        craneHook.position = CGPointMake((CGRectGetMaxX(self.frame) * 0.75),
            CGRectGetMaxY(self.frame))
        craneHook.size = CGSize(width: 60.0, height: 100.0)
        self.addChild(craneHook)
    }
    
}

