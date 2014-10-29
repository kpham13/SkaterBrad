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

    // Jump Properties [Tuan/Vincent]
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false

    // Background Movement [Tina]
    var backgroundSpeed : CGFloat = 1.0
    var roadSpeed : CGFloat = 5.0
    var roadSize : CGSize?
    
    // Node Categories [Tuan/Vincent]
    let heroCategory = 0x1 << 1
    let groundCategory = 0x1 << 2
    let obstacleCategory = 0x1 << 3
  
  
  override func didMoveToView(view: SKView) {
    
    
    var bradJumpTexture = SKTexture(imageNamed: "")
    var bradDuckTexture = SKTexture(imageNamed: "")
    
       

        //spawns a trashcan every 2 seconds -kori/brian
        let spawnBench  = SKAction.runBlock({() in self.spawnBench()})
        let spawnObstacles = SKAction.runBlock({() in self.spawntrashCan()})
        let craneHook = SKAction.runBlock({() in self.spawnCrane()})
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawnBench,delay,delay,spawnObstacles,delay, delay, craneHook])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)

      

        // Swipe Recognizer Setup
        var swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeAction:")
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeRecognizer)
        
        // Swipe Recognizer Setup [Tuan/Vincent]
        var swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeUpAction:")
        swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeUpRecognizer)
        
        var swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeDownAction:")
        swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        self.view?.addGestureRecognizer(swipeDownRecognizer)

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
        
        //Tina/ brad jumping texture
        bradJumpTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        //Tina/ brad ducking texture
        bradDuckTexture.filteringMode = SKTextureFilteringMode.Nearest
        

        hero = SKSpriteNode(texture: bradTexture)
        hero.setScale(0.5)
        hero.position = CGPoint(x: self.frame.size.width * 0.35, y: self.frame.size.height * 0.5) // Change y to ground level
        
        // Physics Body Around Hero
        hero.physicsBody = SKPhysicsBody(circleOfRadius: hero.size.height / 2)
        hero.physicsBody?.dynamic = true
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = UInt32(self.heroCategory)
        hero.physicsBody?.contactTestBitMask = UInt32(self.heroCategory) | UInt32(self.groundCategory)
        self.addChild(hero)
        
        // Ground [Kevin/Tina]
        var ground = SKShapeNode(rectOfSize: CGSize(width: 400, height: self.roadSize!.height))
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
  
  //kori and brian
  func spawnBench(){
    
    var randX: Float = Float(arc4random_uniform(300) + 1)
    //var anotherFloat: Float = Float(randX)
    
    
    //kori/brian
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
  

  func spawntrashCan(){
    
    var randX: Float = Float(arc4random_uniform(500) + 100)
    //var anotherFloat: Float = Float(randX)
    
    
    //kori/brian
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
    self.addChild(trashCan)
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
            self.hero.physicsBody!.applyImpulse(CGVectorMake(0, 35))
            self.jumpNumber += 1
//        }
    }
    

    override func update(currentTime: CFTimeInterval) {
      
      
      //kori and brian
      
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

      
      //Kevin-Tina/ Moving background
      self.enumerateChildNodesWithName("background", usingBlock: { (node, stop) -> Void in
          if let bg = node as? SKSpriteNode {
              bg.position = CGPoint(x: bg.position.x-self.backgroundSpeed, y: bg.position.y)
              if bg.position.x <= -bg.size.width {
                  bg.position = CGPoint(x: bg.position.x+bg.size.width * 2, y: bg.position.y)
              }
          }
          
      })
    
      
      //Kevin-Tina/ Moving road
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
        self.jumpNumber = 0
    }
    
}
