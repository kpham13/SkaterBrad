//
//  GameScene.swift
//  SkaterBrad
//
//  Created by Kevin Pham on 10/27/14.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var hero = SKSpriteNode()
    var road = SKSpriteNode()

    // Jump Properties [Tuan/Vincent]
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false
    
    // Duck Properties
    var duckMode = false

    // Background Movement [Tina]
    var backgroundSpeed : CGFloat = 1.0
    var roadSpeed : CGFloat = 5.0
    var roadSize : CGSize?
    
    // Node Categories [Tuan/Vincent]
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2
    
    // Texture Variables [Tina]
    var bradJumpTexture = SKTexture(imageNamed: "test.jpg")
    var bradTexture = SKTexture(imageNamed: "hero.jpg")
    var bradDuckTexture = SKTexture(imageNamed: "test2.jpg")
    
    override func didMoveToView(view: SKView) {
    
        // Texture Variables

        let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        let craneHook = SKSpriteNode(imageNamed: "crane.gif")
        
        

        // Swipe Up Recognizer  [Tuan/Vincent]
        var swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUpAction:")
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUpRecognizer)
        
        //Swipe Down Recognizer
        var swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDownAction:")
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDownRecognizer)
        
//        self.addChild(obst2)
        
        
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
            self.road = SKSpriteNode(imageNamed: "road.jpg")
            self.road.anchorPoint = CGPointZero
            self.road.position = CGPoint(x: index * Int(self.road.size.width), y: 0)
            self.road.name = "road"
            self.roadSize = road.size
           // println(roadSize)
            self.addChild(self.road)
        }
        
        // Hero [Kevin/Tina]
        bradTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        bradDuckTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //Tina/ brad jumping texture
        bradJumpTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // Hero Ducking Texture [Tina]
        bradDuckTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        hero.name = "Brad"
        hero = SKSpriteNode(texture: bradTexture)
        hero.setScale(0.5)
        hero.position = CGPoint(x: self.frame.size.width * 0.25, y: self.frame.size.height * 0.5) // Change y to ground level
        
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
        
        // Spawns a Trash Can Every 2 Seconds [Brian/Kori]
        let spawn  = SKAction.runBlock({() in self.spawnObstacles()})
        let delay = SKAction.waitForDuration(NSTimeInterval(1.5))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let node = nodeAtPoint(location)
            
//            if node.name! == "RestartButton" {
//                println("REsTART gAME")
//            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        self.hero.position.x = self.frame.size.width * 0.25
        
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
            
            //self.hero.texture = self.bradDuckTexture
            self.jumpNumber += 1
            
        }
        
        //self.hero.texture = self.bradTexture
        
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
            self.roadSpeed = 0
            self.backgroundSpeed = 0
            
            let button = SKShapeNode(ellipseInRect: CGRect(x: CGRectGetMaxX(self.frame)/2, y: CGRectGetMaxY(self.frame)/2, width: 100, height: 100))
            button.position.x = button.position.x - button.frame.width / 2
            button.fillColor = SKColor.blueColor()
            button.name = "RestartButton"
            println(button.position)
            println(button.frame.width)
            println(CGRectGetMaxX(self.frame))
            println(self.frame.width)
            self.addChild(button)
        default:
            println("Trash hit...obstacle?")
        }
    }
    
    // MARK: - OBSTACLES
    // [Brian/Kori]
    
    func spawnObstacles(){
        
        let trashCan = SKSpriteNode(imageNamed: "trashCan.gif")
        let craneHook = SKSpriteNode(imageNamed: "crane.gif")
        let chain = SKSpriteNode(imageNamed: "chain.gif")
        
        trashCan.position = CGPointMake(CGRectGetMinX(self.frame) + self.frame.width, 75)
        trashCan.size = CGSize(width: 35, height: 40)
        trashCan.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 35, height: 40))
        trashCan.physicsBody?.dynamic = false
        trashCan.zPosition = 12
        trashCan.name = "trashCan"
        trashCan.physicsBody?.categoryBitMask = UInt32(self.obstacleCategory)
        self.addChild(trashCan)
        
        
        chain.anchorPoint = CGPointMake(1.0, 1.0)
        chain.position = CGPointMake((CGRectGetMaxX(self.frame) * 0.75), CGRectGetMaxY(self.frame))
        chain.size = CGSize(width: 20, height: 420)
        
        craneHook.anchorPoint = CGPointMake(1.0, 1.0)
        craneHook.position = CGPointMake((CGRectGetMaxX(self.frame) * 0.75 + 39),
            CGRectGetMaxY(self.frame) * 0.38)
        craneHook.size = CGSize(width: 100.0, height: 100.0)
        self.addChild(chain)
        self.addChild(craneHook)
    }

}

