//
//  GameScene.swift
//  SkaterBrad
//
//  Created by Kevin Pham on 10/27/14.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var currentTime = 0.0
    var previousTime = 0.0
    var deltaTime = 0.0
    var jumpNumber = 0
    var jumpTime = 0.0
    var jumpMode = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        var swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeAction:")
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        self.view?.addGestureRecognizer(swipeRecognizer)
    }
    
    
    func swipeAction(swipe: UISwipeGestureRecognizer) {
        self.jumpMode = true
        self.jumpTime = 0.0
        println(self.jumpNumber)
        println(self.jumpTime)
        println(self.deltaTime)
        if self.jumpNumber < 2 && self.jumpTime <= 0.5 {
            bird.physicsBody!.velocity = CGVectorMake(0, 0)
            bird.physicsBody!.applyImpulse(CGVectorMake(0, 25))
            self.jumpNumber += 1
        }
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
