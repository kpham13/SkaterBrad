//
//  GameOverNode.swift
//  SkaterBrad
//
//  Created by Sam Wong on 30/10/2014.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverNode: SKNode {

    var titleLabel: SKLabelNode!
//    var newGameLabel: SKLabelNode
    var scoreLabel: SKLabelNode!
    var grayLayer : SKSpriteNode!
    var replayButton : SKSpriteNode!
    
    init(scene: SKScene) {
        super.init()
        
        // gray screen
        self.grayLayer = SKSpriteNode()
        self.grayLayer.size = CGSize(width: scene.frame.width, height: scene.frame.height)
        self.grayLayer.position = CGPointMake((CGRectGetMaxX(scene.frame)/2), CGRectGetMaxY(scene.frame)/2)
        self.grayLayer.color = SKColor.blackColor()
        self.grayLayer.alpha = 0.5
        self.zPosition = 100
        
        scene.addChild(self.grayLayer)
        // game over label
        self.titleLabel = SKLabelNode(text: "Game Over")
        self.titleLabel.fontName = "Chalkduster"
        self.titleLabel.fontSize = 40
        self.titleLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMidY(scene.frame) + 100 )
        scene.addChild(self.titleLabel)
        
        // reply button
        self.replayButton = SKSpriteNode(imageNamed: "replay")
        self.replayButton.name = "Replay"
        self.replayButton.size = CGSize(width: 60.0, height: 60.0)
        self.replayButton.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMidY(scene.frame) + 30)
        self.replayButton.zPosition = 0
        scene.addChild(self.replayButton)

        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

