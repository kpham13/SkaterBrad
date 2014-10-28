//
//  GameScene.swift
//  SkaterBrad
//
//  Created by Kevin Pham on 10/27/14.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    var hero = SKSpriteNode()
    let obst2 = SKSpriteNode()
//    obst2 = SKSpriteNode(imageNamed: "crane.png")
    
    override func didMoveToView(view: SKView) {

        //obstacles
        
//        obst2 = SKSpriteNode(imageNamed: "crane.png")
        
        self.addChild(obst2)
        
        
        // Physics - setting gravity to game world
        self.physicsWorld.gravity = CGVectorMake(0.0, -9.8)
        
        // Hero
        var bradTexture = SKTexture(imageNamed: "hero.jpg") // Change 90x90 image
        bradTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        hero = SKSpriteNode(texture: bradTexture)
        hero.setScale(0.5)
        hero.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.5) // Change y to ground level
        
        // Determine physics body around Hero
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.height / 2)
        //hero.physicsBody = SKPhysicsBody(rectangleOfSize: <#CGSize#>) // look at later
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.allowsRotation = false
        
        self.addChild(hero)
        
        // Ground
        var groundTexture = SKTexture(imageNamed: "") // Add 336x112 image
        
        var sprite = SKSpriteNode(texture: groundTexture)
        
        sprite.setScale(1.0)
        sprite.position = CGPointMake(self.size.width / 3, sprite.size.height / 2)

        self.addChild(sprite)
        
        var ground = SKNode()
        
        ground.position = CGPointMake(0, groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2))
        ground.physicsBody?.dynamic = false
        
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
    
    override func update(currentTime: CFTimeInterval) {
        //        /* Called before each frame is rendered */
    }

}

