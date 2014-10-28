//
//  GameScene.swift
//  SkaterBrad
//
//  Created by Kevin Pham on 10/27/14.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Jump Properties
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false

    var hero = SKSpriteNode()
    
    // Node Categories
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2
    

    override func didMoveToView(view: SKView) {
        
        // Swipe Recognizer Setup
        var swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUpAction:")
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUpRecognizer)
        
        var swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDownAction:")
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDownRecognizer)

        // Physics - setting gravity to game world
        self.physicsWorld.gravity = CGVectorMake(0.0, -9.8)
        self.physicsWorld.contactDelegate = self
        
        // Hero
        var bradTexture = SKTexture(imageNamed: "hero.jpg") // Change 90x90 image
        bradTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        hero = SKSpriteNode(texture: bradTexture)
        hero.setScale(0.5)
        hero.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.5) // Change y to ground level
        
        // Determine physics body around Hero
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.height / 2)
//        hero.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: hero.size.width, height: hero.size.height))
        //hero.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize) // look at later
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = UInt32(self.heroCategory)
        hero.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.groundCategory)
        
        self.addChild(hero)
        
        // Ground
        var groundTexture = SKTexture(imageNamed: "") // Add 336x112 image
        
        var sprite = SKSpriteNode(texture: groundTexture)
        sprite.setScale(2.0)
        sprite.position = CGPointMake(self.size.width / 2, sprite.size.height / 2)
        println(sprite.frame.height)
        

        self.addChild(sprite)
        
        var ground = SKNode()
        
        ground.position = CGPointMake(0, groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = UInt32(self.groundCategory)
        println(self.frame.size.width)
        println(groundTexture.size().height * 2)
        
//        var ground = SKShapeNode(rectOfSize: CGSize(width: 150, height: 100))
//        ground.fillColor = UIColor.redColor()
//        ground.position = CGPointMake(100,20)
//        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: ground.frame.size.width, height: ground.frame.size.height))
//        ground.physicsBody?.dynamic = false
//        
        self.addChild(ground)
        
//        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        /* Called when a touch begins */
//        
//        for touch: AnyObject in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
        }
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
        self.jumpNumber = 0
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if self.jumpMode == true {
            self.currentTime = currentTime
            self.deltaTime = self.currentTime - self.previousTime
            self.previousTime = currentTime
            self.jumpTime = self.jumpTime + self.deltaTime
        }
    }
}

