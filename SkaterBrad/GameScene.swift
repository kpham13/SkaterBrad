//
//  GameScene.swift
//  SkaterBrad
//
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit //3

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gameViewController : GameViewController? //4
    
    // User Defaults
    var userDefaultsController : UserDefaultsController?
    
    var hero = SKSpriteNode()
    var road = SKSpriteNode()
    // Factor to set entry X position for hero
    let heroPositionX : CGFloat = 0.2
    
    // Background Movement [Tina]
    var backgroundSpeed : CGFloat = 1.0
    var roadSpeed : CGFloat = 3.0 // 6.0
    var roadSize : CGSize?
    
    // Score [KP]
    var scoreTextLabel: SKLabelNode!
    var score = 0
    
    // High Score [KP]
    let highScoreText = SKLabelNode(fontNamed: "Chalkduster")
    var highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
    
    // Jump Properties [Tuan/Vincent]
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false
    
    // Coin spritenode [Tuan]
   // let coin = SKSpriteNode(imageNamed: "taco.gif")
    
    // Duck Properties
    var duckMode = false
    
    // FallAnimation Properties
    var fallMode = false
    
    // Node Categories [Tuan/Vincent]
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2
    let obstacleCategory = 0x1 << 3
    let scoreCategory = 0x1 << 4
    let coinCategory = 0x1 << 5
    let contactCategory = 0x1 << 6
    let hookCategory = 0x1 << 7
    
    // Texture Variables [Tina]
    var bradJumpTexture = SKTexture(imageNamed: "BradJump0")
    var bradTexture = SKTexture(imageNamed: "BradNormal")
    var bradDuckTexture = SKTexture(imageNamed: "BradDuck")
    var bradJumpDownTexture = SKTexture(imageNamed: "BradJump1")
    var bradFallTextures: Array<SKTexture> = [
        SKTexture(imageNamed: "BradFall0"),
        SKTexture(imageNamed: "BradFall1"),
        SKTexture(imageNamed: "BradFall2"),
        SKTexture(imageNamed: "BradFall3"),
        SKTexture(imageNamed: "BradFall4"),
        SKTexture(imageNamed: "BradFall5"),
        SKTexture(imageNamed: "BradFall6"),
        SKTexture(imageNamed: "BradFall7"),
    ]
    
    // Menu & Buttons
    var soundOption: SoundNode?
    var newGameMenu: NewGameNode?
    var gameOverMenu: GameOverNode?
    var gameCenterButton: SKSpriteNode? //14
    var showNewGameMenu = true
    var showGameOverMenu = false
    var playSound = true
    
    // Game Over Screen
    var gameOverLabel: SKLabelNode!
    var screenDimmerNode : SKSpriteNode!
    var replayButton : SKSpriteNode!
   
    // MARK: - DID MOVE TO VIEW
    override func didMoveToView(view: SKView) {
        self.registerAppTransitionObservers()
        self.userDefaultsController = UserDefaultsController()
        
        self.soundOption = SoundNode(playSound: self.playSound)
        self.newGameMenu = NewGameNode(scene: self, playSound: self.playSound)
        self.addChild(self.newGameMenu!)

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
            let bg = SKSpriteNode(imageNamed: "Background\(index)")
            bg.anchorPoint = CGPointZero
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 110)
            bg.name = "background"
            //bg.zPosition = 100
            self.addChild(bg)
        }
        
        // Roads [Tina]
        for var index = 0; index < 2; ++index {
            self.road = SKSpriteNode(imageNamed: "road")
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
        for texture in self.bradFallTextures {
            texture.filteringMode = SKTextureFilteringMode.Nearest
        }
        
        self.hero.name = "Brad"
        self.hero = SKSpriteNode(texture: bradTexture)
        self.hero.setScale(1.0)
        self.hero.position = CGPoint(x: self.frame.size.width * self.heroPositionX, y: self.frame.size.height * 0.5) // Change y to ground level
        self.hero.anchorPoint = CGPointZero
        self.hero.zPosition = 100
        
        // Physics Body Around Hero
        self.hero.physicsBody = SKPhysicsBody(rectangleOfSize: hero.size, center: CGPointMake(hero.frame.width / 2, hero.frame.height / 2))
        self.hero.physicsBody?.dynamic = true
        self.hero.physicsBody?.allowsRotation = false
        self.hero.physicsBody?.categoryBitMask = UInt32(self.heroCategory)
        self.hero.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.groundCategory) | UInt32(self.obstacleCategory) | UInt32(self.contactCategory) | UInt32(self.scoreCategory)
        self.hero.physicsBody?.collisionBitMask = UInt32(self.groundCategory) | UInt32(self.obstacleCategory) | UInt32(self.contactCategory)
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
        
        // Game Score [KP]
        self.scoreTextLabel = SKLabelNode(fontNamed: "Chalkduster")
        self.scoreTextLabel.text = "0"
        self.scoreTextLabel.fontSize = 50
        self.scoreTextLabel.color = UIColor.blackColor()
        self.scoreTextLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height * 0.08)
        self.scoreTextLabel.zPosition = 100
        self.scoreTextLabel.hidden = true
        self.addChild(self.scoreTextLabel)
        
        //NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highscore")
        // High Score [KP]
        self.highScoreText.text = "High Score: \(self.highScore)"
        self.highScoreText.fontSize = 15
        self.highScoreText.color = UIColor.blackColor()
        self.highScoreText.verticalAlignmentMode = SKLabelVerticalAlignmentMode(rawValue: 3)!
        self.highScoreText.position = CGPointMake(CGRectGetMaxX(self.frame) * 0.77, CGRectGetMaxY(self.frame) * 0.01)
        self.highScoreText.zPosition = 100
        self.addChild(self.highScoreText)
    }
    
    // MARK: - UPDATE
    
    override func update(currentTime: CFTimeInterval) {
        // Lock Hero's X Position [Tina]
        if fallMode == false {
            self.hero.position.x = self.frame.size.width * self.heroPositionX
        }
        
        
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
    
    // MARK: - TOUCHES BEGAN
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var touch = touches.anyObject() as UITouch
        var location = touch.locationInNode(self)
        
        if self.showNewGameMenu == true {
            self.newGameMenuTouches(touches)
        }
        
        if self.showGameOverMenu == true {
            self.gameOverMenuTouches(touches)
        }
        
//        if self.nodeAtPoint(location) == self.playButton {
//            self.runAction(SKAction.runBlock({ () -> Void in
//                self.playButton.removeFromParent()
//                self.playGame()
//            }))
//        }
//        
//        if self.nodeAtPoint(location) == self.menuButton {
//            self.runAction(SKAction.runBlock({ () -> Void in
//                self.menuButton.removeFromParent()
//                self.restartGame()
//            }))
//        }
    }
    
    // [Sam]
    func newGameMenuTouches(touches: NSSet) {
        
        var touch = touches.anyObject() as UITouch
        var location = touch.locationInNode(self.newGameMenu)
        
        println(" ")
        println("playnow button zposition : \(self.newGameMenu?.playButton.zPosition)")
        println("playnow button position x : \(self.newGameMenu?.playButton.position.x)")
        println("playnow button position y : \(self.newGameMenu?.playButton.position.y)")
        
        println("node name : \(self.nodeAtPoint(location).name)")
        println("node zposition : \(self.nodeAtPoint(location).zPosition)")
        println("node position.x : \(self.nodeAtPoint(location).position.x)")
        println("node position.y : \(self.nodeAtPoint(location).position.y)")
        
        println("tap location x : \(touch.locationInNode(self).x)")
        println("tap location y : \(touch.locationInNode(self).y)")
        
        
        if self.nodeAtPoint(location).name == "PlayNow" {
            self.runAction(SKAction.runBlock({ () -> Void in
                self.showNewGameMenu = false
                self.showGameOverMenu = false
                self.newGameMenu?.removeFromParent()
                self.scoreTextLabel.hidden = false
                self.startSpawn()
            }))
        }
        
        if self.nodeAtPoint(location).name == "SoundOn" {
            self.playSound = false
            self.soundOption!.audioPlayer.stop()
            self.newGameMenu?.turnSoundOnOff(SoundButtonSwitch.Off)
        } else if self.nodeAtPoint(location).name == "SoundOff" {
            self.playSound = true
            self.soundOption!.audioPlayer.play()
            self.newGameMenu?.turnSoundOnOff(SoundButtonSwitch.On)
        }
        
        //16
        if self.nodeAtPoint(location).name == "GameCenterButton" {
            self.gameViewController?.showLeaderboardAndAchievements(true)
        }
        
    }
    
    // [Sam]
    func gameOverMenuTouches(touches: NSSet) {
        var touch = touches.anyObject() as UITouch
        var location = touch.locationInNode(self)
//        var location = touch.locationInNode(self.gameOverMenu)
        
        println(" ")
        println("replay button zposition : \(self.replayButton.zPosition)")
        println("replay button position x : \(self.replayButton.position.x)")
        println("replay button position y : \(self.replayButton.position.y)")
        
//        println("replay button zposition : \(self.gameOverMenu?.replayButton.zPosition)")
//        println("replay button position x : \(self.gameOverMenu?.replayButton.position.x)")
//        println("replay button position y : \(self.gameOverMenu?.replayButton.position.y)")
        
        println("node name : \(self.nodeAtPoint(location).name)")
        println("node zposition : \(self.nodeAtPoint(location).zPosition)")
        println("node position.x : \(self.nodeAtPoint(location).position.x)")
        println("node position.y : \(self.nodeAtPoint(location).position.y)")
        
        println("tap location x : \(touch.locationInNode(self).x)")
        println("tap location y : \(touch.locationInNode(self).y)")
        
        if self.nodeAtPoint(location).name == "Replay" {
                self.gameOverMenu?.removeFromParent()
                self.restartGame()
        }
        
//        if self.nodeAtPoint(location) == self.gameOverMenu?.replayButton {
//            self.runAction(SKAction.runBlock({ () -> Void in
//                self.gameOverMenu?.removeFromParent()
//                self.restartGame()
//            }))
//        }
    }

    // MARK: - DID BEGIN CONTACT
    
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
            self.scoreTextLabel.text = String(self.score)
            self.scoreTextLabel.runAction(SKAction.scaleTo(2.0, duration: 0.1))
            self.scoreTextLabel.runAction(SKAction.scaleTo(1.0, duration: 0.1))
        case UInt32(self.heroCategory) | UInt32(self.coinCategory):
          // calls function that removes coin on contact
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
              heroDidCollideWithCoin(contact.bodyB.node as SKSpriteNode, hero: contact.bodyA.node as SKSpriteNode)
            }

            println("CHA CHING")
            //self.coin.removeFromParent()
            
            if self.playSound == true {
                let ranNum = arc4random_uniform(UInt32(3))
                if ranNum == 0 {
                    runAction(SKAction.playSoundFileNamed("Ohdamn.wav", waitForCompletion: false))
                }
                else if ranNum == 1 {
                    runAction(SKAction.playSoundFileNamed("Goseahawks.wav", waitForCompletion: false))
                }
                else if ranNum == 2 {
                    runAction(SKAction.playSoundFileNamed("Twitterrocks.wav", waitForCompletion: false))
                }
            }
            
            self.score += 10
            self.scoreTextLabel.text = String(self.score)
            self.scoreTextLabel.runAction(SKAction.scaleTo(2.0, duration: 0.1))
            self.scoreTextLabel.runAction(SKAction.scaleTo(1.0, duration: 0.1))
        case UInt32(self.heroCategory) | UInt32(self.contactCategory):
            println("Hero hit contact node")
            
            if self.playSound == true {
                let ranNum = arc4random_uniform(UInt32(2))
                if ranNum == 0 {
                    runAction(SKAction.playSoundFileNamed("Getitnexttime.wav", waitForCompletion: false))
                }
                else if ranNum == 1 {
                    runAction(SKAction.playSoundFileNamed("5MinuteWaterBreak.mp3", waitForCompletion: false))
                }
            }

            self.fallMode = true
            self.endGame()
        default:
            println("Hero hit something...not given a category....should not happen....")
        }
    }

    // MARK: - HERO ACTIONS
    // [Tuan/Vincent]
    
    func swipeUpAction(swipe: UISwipeGestureRecognizer) {
        if self.duckMode == false && self.fallMode == false {
            if self.jumpMode == false {
                self.jumpTime = 0.0
            }
            self.jumpMode = true
            //         Jump Limit Logic ------ Uncomment to use.
            if self.jumpNumber < 2 && self.jumpTime <= 0.5 {
                self.hero.physicsBody!.velocity = CGVectorMake(0, 0)
                self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 150))
                self.hero.texture = self.bradJumpTexture
                self.jumpNumber += 1
            }
        } else if self.duckMode == true && self.fallMode == false {
            self.hero.yScale = 1.0
            self.hero.texture = bradTexture
            self.duckMode = false
        }
    }
    
    func swipeDownAction(swipe: UISwipeGestureRecognizer) {
        if self.duckMode == false && self.jumpMode == false && self.fallMode == false {
            println("Swipe down")
            self.hero.yScale = 0.66
            self.hero.texture = bradDuckTexture
            self.duckMode = true
        }
    }

    func heroFallAnimation(completionHandler: () -> Void) {
        println("Fall animation")
        let fallAnimation = SKAction.animateWithTextures(self.bradFallTextures, timePerFrame: 0.1)
        let moveUp = SKAction.moveTo(CGPoint(x: self.roadSize!.width * 0.6, y: self.frame.height / 2), duration: 0.5)
        let moveDown = SKAction.moveTo(CGPoint(x: self.roadSize!.width * 0.8, y: self.roadSize!.height * 0.9), duration: 0.3)
        let upDown = SKAction.sequence([moveUp, moveDown])
        
        self.jumpMode = false
        self.duckMode = false
        self.hero.runAction(fallAnimation)
        self.hero.runAction(upDown, completion: { () -> Void in
            completionHandler()
        })
    }
    
    // MARK: - OBSTACLES
    // [Brian/Kori]
    
    func spawnBench(){
      //var randX: Float = 1.0
      //Float(arc4random_uniform(300) + 1)

        //var anotherFloat: Float = Float(randX)
        
        // Vertical Nodes for Game Score [Kevin]
        let vertical = SKNode()
        vertical.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, 0)
        vertical.zPosition = 100
        vertical.name = "vertical"
        self.addChild(vertical)
        
        let bench = SKSpriteNode(imageNamed: "Bench")
        bench.size = CGSize(width: 105, height: 60)
        bench.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, (self.roadSize!.height + (bench.size.height * 0.3)))
        bench.zPosition = 110
        bench.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 105, height: 58))
        bench.physicsBody?.dynamic = false
        bench.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        bench.physicsBody?.node?.name = "bench"
        vertical.addChild(bench)
        
        let benchScoreContact = SKNode()
//        benchScoreContact.size = CGSize(width: 5, height: self.frame.size.height)
//        benchScoreContact.color = SKColor.redColor()
        benchScoreContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, CGRectGetMidY(self.frame))
        benchScoreContact.zPosition = 105
        benchScoreContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: self.frame.size.height))
        benchScoreContact.physicsBody?.dynamic = false
        benchScoreContact.physicsBody?.categoryBitMask = UInt32(self.scoreCategory)
        benchScoreContact.physicsBody?.node?.name = "benchScoreContact"
        benchScoreContact.physicsBody?.collisionBitMask = 0
        vertical.addChild(benchScoreContact)
        
        let benchLoseContact = SKSpriteNode()
        benchLoseContact.size = CGSize(width: 2, height: bench.size.height * 0.6)
        //benchLoseContact.color = SKColor.redColor() // Delete later
        benchLoseContact.anchorPoint = CGPointMake(0.5, 0)
        benchLoseContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/ - bench.size.width / 2, self.roadSize!.height)
        benchLoseContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: bench.size.height * 0.6))
        benchLoseContact.physicsBody?.dynamic = false
        benchLoseContact.physicsBody?.categoryBitMask = UInt32(self.contactCategory)
        vertical.addChild(benchLoseContact)
    }
    func spawnTrashcan() {
      // var randX: Float = 1.0
      //Float(arc4random_uniform(500) + 100)
        //var anotherFloat: Float = Float(randX)
        
        // Vertical Nodes for Game Score [Kevin]
        let vertical = SKNode()
        vertical.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, 0)
        vertical.zPosition = 100
        vertical.name = "vertical"
        self.addChild(vertical)

        let trashCan = SKSpriteNode(imageNamed: "TrashCan")
        trashCan.size = CGSize(width: 35, height: 40)
        trashCan.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, (self.roadSize!.height + (trashCan.size.height / 2)))
        trashCan.zPosition = 110
        trashCan.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 30, height: 40))
        trashCan.physicsBody?.dynamic = false
        trashCan.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        trashCan.physicsBody?.node?.name = "trashCan"
        vertical.addChild(trashCan)
        
        let trashScoreContact = SKNode()
        //trashScoreContact.size = CGSize(width: 5, height: self.frame.size.height)
        //trashScoreContact.color = SKColor.blueColor()
        trashScoreContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, CGRectGetMidY(self.frame))
        trashScoreContact.zPosition = 105
        trashScoreContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: self.frame.size.height))
        trashScoreContact.physicsBody?.dynamic = false
        trashScoreContact.physicsBody?.categoryBitMask = UInt32(self.scoreCategory)
        trashScoreContact.physicsBody?.node?.name = "trashScoreContact"
        vertical.addChild(trashScoreContact)
        
        let trashLoseContact = SKSpriteNode()
        trashLoseContact.size = CGSize(width: 1, height: trashCan.size.height / 2)
        //trashLoseContact.color = SKColor.redColor() // Delete Later
        trashLoseContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/ - trashCan.size.width / 4, self.roadSize!.height + trashCan.size.height / 2 - 0.5) //edited by brian 10/30/2014 10:40pm
        trashLoseContact.zPosition = 200
        trashLoseContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1, height: trashCan.size.height / 2))
        trashLoseContact.physicsBody?.dynamic = false
        trashLoseContact.physicsBody?.categoryBitMask = UInt32(self.contactCategory)
        vertical.addChild(trashLoseContact)
    }
    
    func spawnCrane(){
      var randX = Float(arc4random_uniform(600) + 1)
        // Vertical Nodes for Game Score [Kevin]
        let vertical = SKNode()
        vertical.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, 0)
        vertical.zPosition = 100
        vertical.name = "vertical"
        self.addChild(vertical)
        
        let chain = SKSpriteNode(imageNamed: "Chain")
        chain.size = CGSize(width: 3, height: 350)
        chain.anchorPoint = CGPointMake(0.5, 1.0)
        chain.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, CGRectGetMaxY(self.frame))
        chain.zPosition = -5
        vertical.addChild(chain)
        
        let craneHook = SKSpriteNode(imageNamed: "CraneHook")
        craneHook.anchorPoint = CGPointMake(0.5, 1.0)
        craneHook.size = CGSize(width: 40.0, height: 60.0)
        craneHook.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, CGRectGetMaxY(self.frame) - chain.size.height * 0.95)
        craneHook.zPosition = -5
        craneHook.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 40, height: 60))
        craneHook.physicsBody?.dynamic = false
        //craneHook.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        // vertical.addChild(craneHook) - delete if using conditional addChild below
        
        let beem = SKSpriteNode(imageNamed: "SteelBeam")
        beem.zPosition = 112
        beem.size = CGSize(width: 250, height: 30)
        beem.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, CGRectGetMaxY(self.frame) - chain.size.height - craneHook.size.height * 0.70)
        beem.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 250, height: 30))
        beem.physicsBody?.dynamic = false
        beem.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        
        let beemLoseContact = SKSpriteNode()
        beemLoseContact.size = CGSize(width: 1, height: beem.size.height / 2)
        //beemLoseContact.color = SKColor.redColor()
        beemLoseContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/ - (beem.size.width / 2.1), CGRectGetMaxY(self.frame) - chain.size.height - craneHook.size.height * 0.70)
        beemLoseContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1, height: beem.size.height / 2))
        beemLoseContact.physicsBody?.dynamic = false
        beemLoseContact.physicsBody?.categoryBitMask = UInt32(self.contactCategory)

        if randX < 300 {
            craneHook.physicsBody?.categoryBitMask = UInt32(self.hookCategory)
            vertical.addChild(craneHook)
            vertical.addChild(beem)
            vertical.addChild(beemLoseContact)
        } else {
            craneHook.physicsBody?.categoryBitMask = UInt32(self.contactCategory)
            vertical.addChild(craneHook)
        }
        
        let craneScoreContact = SKNode()
        //craneScoreContact.size = CGSize(width: 5, height: self.frame.size.height)
        //craneScoreContact.color = SKColor.blueColor()
        craneScoreContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, CGRectGetMidY(self.frame))
        craneScoreContact.zPosition = 105
        craneScoreContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: self.frame.size.height))
        craneScoreContact.physicsBody?.dynamic = false
        craneScoreContact.physicsBody?.categoryBitMask = UInt32(self.scoreCategory)
        craneScoreContact.physicsBody?.node?.name = "benchScoreContact"
        vertical.addChild(craneScoreContact)
    }
    
    func spawnPylon() {
        
        //var randX = arc4random_uniform(300) + 2
        let vertical = SKNode()
        vertical.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, 0)
        vertical.zPosition = 100
        vertical.name = "vertical"
        self.addChild(vertical)
        
        let pylon = SKSpriteNode(imageNamed: "Pylon")
        pylon.size = CGSize(width: 25, height: 35)
        pylon.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, (self.roadSize!.height) + pylon.size.height / 2)
        pylon.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 25, height: 35))
        pylon.physicsBody?.dynamic = false
        pylon.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        //pylon.physicsBody?.node?.name = "trashCan"
        vertical.addChild(pylon)
        
        let pylonScoreContact = SKNode()
        pylonScoreContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, CGRectGetMidY(self.frame))
        pylonScoreContact.zPosition = 105
        pylonScoreContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: self.frame.size.height))
        pylonScoreContact.physicsBody?.dynamic = false
        pylonScoreContact.physicsBody?.categoryBitMask = UInt32(self.scoreCategory)
        pylonScoreContact.physicsBody?.node?.name = "pylonScoreContact"
        vertical.addChild(pylonScoreContact)
        
        let pylonLoseContact = SKSpriteNode()
        pylonLoseContact.size = CGSize(width: 1, height: pylon.size.height / 2)
        //pylonLoseContact.color = SKColor.redColor() // Delete Later
        pylonLoseContact.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/ - pylon.size.width / 2, self.roadSize!.height + pylon.size.height / 2)
        pylonLoseContact.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 1, height: pylon.size.height / 2))
        pylonLoseContact.physicsBody?.dynamic = false
        pylonLoseContact.physicsBody?.categoryBitMask = UInt32(self.contactCategory)
        vertical.addChild(pylonLoseContact)
    }
    
    // Spawn coin [Tuan] - edited by [Kori-Brian]
    func spawnCoin() {
        //var randX = arc4random_uniform(100)
        let coin = SKSpriteNode(imageNamed: "Taco")

        coin.position = CGPointMake(CGRectGetMaxX(self.frame) /*+ CGFloat(randX)*/, 350)
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
 
    //removing coin when hero collides - [Kori-Brian]
    func heroDidCollideWithCoin(coin: SKSpriteNode, hero:SKSpriteNode) {
        println("Hit-coin")
        coin.removeFromParent()
      }

    // MARK: - MENU SCREENS
    // [Sam]
    
    func endGame() {
        // stop audio
        self.soundOption!.audioPlayer.stop()
        
        // stop screen
        self.hero.physicsBody?.dynamic = false
        self.roadSpeed = 0
        self.backgroundSpeed = 0
        
        // hero fall animation - Vincent
        self.heroFallAnimation { () -> Void in
            //        self.gameOverMenu = GameOverNode(scene: self)
            self.generateGameOverScreen()
            self.showGameOverMenu = true
            self.showNewGameMenu = false
            
            //        self.scene?.paused = true
            //        self.coin.removeFromParent()
            
            self.scene?.removeActionForKey("startSpawn")
        }
    }
    
    // [Sam]
    func restartGame() {
        self.roadSpeed = 5.0
        self.backgroundSpeed = 1.0
        
        var scene = GameScene(size: self.size)
        scene.gameViewController = self.gameViewController
        
        let skView = self.view! as SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.size = skView.bounds.size
        scene.playSound = self.playSound
        skView.presentScene(scene)

    }
    
    // [Sam]
    func startSpawn() {
        var rand = Float(arc4random_uniform(2) + 1)
        // hero physics starts
        self.hero.physicsBody?.dynamic = true
        
        // Obstacles Spawn [Brian/Kori]
        let spawnBench  = SKAction.runBlock({() in self.spawnBench()})
        let spawnTrashcan = SKAction.runBlock({() in self.spawnTrashcan()})
        let craneHook = SKAction.runBlock({() in self.spawnCrane()})
        let spawnPylon = SKAction.runBlock({() in self.spawnPylon()})
        var obstacleArray = [SKAction]()
        // Coin [Tuan]
        let spawnCoin = SKAction.runBlock({() in self.spawnCoin()})
        var delay = SKAction.waitForDuration(NSTimeInterval(rand))
        var craneDelay = SKAction.waitForDuration(NSTimeInterval(2))

      
        for var i = 0; i < 30; i++ {
          var rand = Float(arc4random_uniform(5) + 1)
          println(rand)
          switch rand {
          case 1:
            obstacleArray.append(delay)
            obstacleArray.append(spawnBench)
          case 2:
            obstacleArray.append(craneDelay)
            obstacleArray.append(craneHook)
            obstacleArray.append(craneDelay)
          case 3:
            obstacleArray.append(delay)
            obstacleArray.append(spawnPylon)
          case 4:
            obstacleArray.append(delay)
            obstacleArray.append(spawnTrashcan)
          case 5:
            obstacleArray.append(delay)
            obstacleArray.append(spawnCoin)
          default:
            obstacleArray.append(delay)
            obstacleArray.append(spawnCoin)
          }
        }
      
      
        let spawnThenDelay = SKAction.sequence(obstacleArray)
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever, withKey: "startSpawn")
    }
    
    // MARK: - APP TRANSITION OBSERVERS
    
    // [Sam]
    func registerAppTransitionObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive", name:UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name:UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func applicationWillResignActive() {
        //self.soundOption!.audioPlayer.stop()
        self.scene?.paused = true
    }
    
    func applicationDidEnterBackground() {
        //self.soundOption!.audioPlayer.stop()
        self.scene?.paused = true
    }
    
    func applicationWillEnterForeground() {
        self.scene?.paused = false
        //self.soundOption!.audioPlayer.play()
    }
    
    func generateGameOverScreen() {
        // screen dimmer node
        self.screenDimmerNode = SKSpriteNode()
        self.screenDimmerNode.size = CGSize(width: self.frame.width, height: self.frame.height)
        self.screenDimmerNode.position = CGPointMake((CGRectGetMaxX(self.frame)/2), CGRectGetMaxY(self.frame)/2)
        self.screenDimmerNode.color = SKColor.blackColor()
        self.screenDimmerNode.alpha = 0.5
        //self.zPosition = 100
        self.addChild(self.screenDimmerNode)
        
        // game over label
        self.gameOverLabel = SKLabelNode(text: "Game Over")
        self.gameOverLabel.fontName = "Chalkduster"
        self.gameOverLabel.fontSize = 40
        self.gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height * 0.7)
        self.gameOverLabel.zPosition = 200
        self.addChild(self.gameOverLabel)
        
        // replay button
        self.replayButton = SKSpriteNode(imageNamed: "replay")
        self.replayButton.name = "Replay"
        self.replayButton.size = CGSize(width: 60.0, height: 60.0)
        self.replayButton.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height * 0.55)
        self.replayButton.zPosition = 200
        self.addChild(self.replayButton)
        
        // High Score [KP]
        self.userDefaultsController?.highScoreCheck(self)

        // Game Center [KP] //12
        if self.gameViewController?.gameCenterEnabled == true {
            println(self.gameViewController?.gameCenterEnabled)
            let gameCenterScore = Int64(self.score)
            self.gameViewController!.reportScoreToGameCenter(gameCenterScore, forLeaderboard: "MF.SkaterBrad")
        }
    }

}
