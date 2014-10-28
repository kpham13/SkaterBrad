//
//  GameScene.swift
//  SkaterBrad
//
//  Created by Kevin Pham on 10/27/14.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // Jump Properties
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false

    var hero = SKSpriteNode()
    var backgroundSpeed : CGFloat = 1.0
    var roadSpeed : CGFloat = 5.0
    var roadSize : CGSize?
    
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2

    override func didMoveToView(view: SKView) {
        
        // Swipe Recognizer Setup
        var swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeAction:")
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeRecognizer)
        
        // Physics - setting gravity to game world
        self.physicsWorld.gravity = CGVectorMake(0.0, -9.8)
        // Background
        
        for var index = 0; index < 2; ++index {
            let bg = SKSpriteNode(imageNamed: "bg\(index).jpg")
            bg.anchorPoint = CGPointZero
            bg.position = CGPoint(x: index * Int(bg.size.width), y: 0)
            bg.name = "background"
            self.addChild(bg)
        }
        
        // Roads
        for var index = 0; index < 2; ++index {
            let road = SKSpriteNode(imageNamed: "road.jpg")
            road.anchorPoint = CGPointZero
            road.position = CGPoint(x: index * Int(road.size.width), y: 0)
            road.name = "road"
            self.roadSize = road.size
            self.addChild(road)
        }

        
        
        // Hero
        var bradTexture = SKTexture(imageNamed: "hero.jpg") // Change 90x90 image
        bradTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        hero = SKSpriteNode(texture: bradTexture)
        hero.setScale(0.5)
        hero.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.5) // Change y to ground level
        
        // Determine physics body around Hero
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.height / 2)
        //hero.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize) // look at later
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = UInt32(self.heroCategory)
        
        self.addChild(hero)
        
        // Ground
//        var groundTexture = SKTexture(imageNamed: "") // Add 336x112 image
//        
//        var sprite = SKSpriteNode(texture: groundTexture)
//        sprite.setScale(2.0)
//        sprite.position = CGPointMake(self.size.width / 2, sprite.size.height / 2)
//
//        self.addChild(sprite)
//        
//        var ground = SKNode()
//        
//        ground.position = CGPointMake(0, groundTexture.size().height)
//        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2))
//        ground.physicsBody?.dynamic = false
        
        
        var ground = SKShapeNode(rectOfSize: CGSize(width: 400, height: self.roadSize!.height))
        ground.hidden = true
        ground.position = CGPoint(x: 0, y: self.roadSize!.height * 0.5)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: self.roadSize!)
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = UInt32(self.groundCategory)

        self.addChild(ground)
        
        // / Setup your scene here /
        // let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        // myLabel.text = "Hello, World!";
        // myLabel.fontSize = 65;
        // myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        //
        // self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // / Called when a touch begins /
        //
        // for touch: AnyObject in touches {
        // let location = touch.locationInNode(self)
        //
        // let sprite = SKSpriteNode(imageNamed:"Spaceship")
        //
        // sprite.xScale = 0.5
        // sprite.yScale = 0.5
        // sprite.position = location
        //
        // let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
        //
        // sprite.runAction(SKAction.repeatActionForever(action))
        //
        // self.addChild(sprite)
    }

    func swipeAction(swipe: UISwipeGestureRecognizer) {
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
    
    override func update(currentTime: CFTimeInterval) {
        self.enumerateChildNodesWithName("background", usingBlock: { (node, stop) -> Void in
            if let bg = node as? SKSpriteNode {
                bg.position = CGPoint(x: bg.position.x-self.backgroundSpeed, y: bg.position.y)
                if bg.position.x <= -bg.size.width {
                    bg.position = CGPoint(x: bg.position.x+bg.size.width * 2, y: bg.position.y)
                }
            }
            
        })
        
        self.enumerateChildNodesWithName("road", usingBlock: { (node, stop) -> Void in
            if let road = node as? SKSpriteNode {
                road.position = CGPoint(x: road.position.x-self.roadSpeed, y: road.position.y)
                if road.position.x <= -road.size.width {
                    road.position = CGPoint(x: road.position.x+road.size.width * 2, y: road.position.y)
                }
            }
            
        })
        
        if self.jumpMode == true {
            self.currentTime = currentTime
            self.deltaTime = self.currentTime - self.previousTime
            self.previousTime = currentTime
            self.jumpTime = self.jumpTime + self.deltaTime
        }
    }
}
