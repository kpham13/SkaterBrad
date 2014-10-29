//
//  StartScene.swift
//  SkaterBrad
//
//  Created by Sam Wong on 28/10/2014.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    let playButton = SKSpriteNode(imageNamed: "play")
    
    override func didMoveToView(view: SKView) {
        let bg = SKSpriteNode(imageNamed: "bg1.jpg")
        bg.anchorPoint = CGPointZero
        bg.position = CGPoint(x: 0, y: 0)
        bg.name = "background"
        self.addChild(bg)
        
        self.playButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        self.addChild(self.playButton)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.playButton {
                var scene = GameScene(size: self.size)
                let skView = self.view! as SKView
                skView.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView.bounds.size
                skView.presentScene(scene)
            }
        }
    }
//    
//    let skView = self.view as SKView
//    let myScene = StartScene(size: skView.frame.size)
//    println(myScene.size)
//    skView.presentScene(myScene)
}

