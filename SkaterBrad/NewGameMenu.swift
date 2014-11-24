//
//  NewGrameNode.swift
//  SkaterBrad
//
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import UIKit
import SpriteKit

enum SoundButtonSwitch {
    case On
    case Off
}

class NewGameNode: SKNode {
    var titleLabel: SKLabelNode!
    var directionLabel: SKLabelNode!
    var playButton: SKSpriteNode!
    var soundOnButton: SKSpriteNode!
    var soundOffButton: SKSpriteNode!
    var gameCenterButton: SKSpriteNode! //xx
    
    init(scene: SKScene, playSound: Bool) {
        super.init()

        self.titleLabel = SKLabelNode(text: "Skater Brad")
        self.titleLabel.fontName = "SkaterDudes"
        self.titleLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) * 0.8)
        self.titleLabel.zPosition = 5
        
        self.directionLabel = SKLabelNode(text: "Swipe up to jump")
        self.directionLabel.fontName = "SkaterDudes"
        self.directionLabel.zPosition = 5
        
        // New Game Button
        self.playButton = SKSpriteNode(imageNamed: "playNow.png")
        self.playButton.name = "PlayNow"
        self.playButton.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMidY(scene.frame))
        self.playButton.zPosition = 10
        self.playButton.xScale = 0.6
        self.playButton.yScale = 0.6
        self.addChild(self.playButton)
        
        // Sound On Button
        self.soundOnButton = SKSpriteNode(imageNamed: "SoundOn")
        self.soundOnButton.position = CGPoint(x: CGRectGetMaxX(scene.frame) - self.soundOnButton.frame.width / 2, y: CGRectGetMaxY(scene.frame) - self.soundOnButton.frame.height / 2)
        self.soundOnButton?.name = "SoundOn"
        self.soundOnButton.xScale = 0.40
        self.soundOnButton.yScale = 0.40
        self.soundOnButton.zPosition = 2.0
        
        // Sound Off Button
        self.soundOffButton = SKSpriteNode(imageNamed: "SoundOff")
        self.soundOffButton.position = CGPoint(x: CGRectGetMaxX(scene.frame) - self.soundOffButton.frame.width, y: CGRectGetMaxY(scene.frame) - self.soundOffButton.frame.height / 2)
        self.soundOffButton?.name = "SoundOff"
        self.soundOffButton.xScale = 0.40
        self.soundOffButton.yScale = 0.40
        self.soundOffButton.zPosition = 2.0
        
        if playSound == true  {
            self.addChild(self.soundOnButton)
        } else {
            self.addChild(self.soundOffButton)
        }
        
        // Game Center Button [KP] //15
        self.gameCenterButton = SKSpriteNode(imageNamed: "GameCenter")
        self.gameCenterButton?.name = "GameCenterButton"
        self.gameCenterButton?.zPosition = 10
        self.gameCenterButton.xScale = 0.8
        self.gameCenterButton.yScale = 0.8
        self.gameCenterButton?.anchorPoint = CGPointMake(0, 0)
        
        if scene.frame.size.height == 568 {
            self.titleLabel.fontSize = 40
            self.directionLabel.fontSize = 18
            self.directionLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) * 0.13)
            self.gameCenterButton.position = CGPointMake(CGRectGetMaxX(scene.frame) * (-0.04), CGRectGetMaxY(scene.frame) * (-0.03))
        } else if scene.frame.size.height == 667 {
            self.titleLabel.fontSize = 45
            self.directionLabel.fontSize = 20
            self.directionLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) * 0.11)
            self.gameCenterButton.position = CGPointMake(CGRectGetMaxX(scene.frame) * (-0.01), CGRectGetMaxY(scene.frame) * (-0.025))
        } else if scene.frame.size.height == 736 {
            println(scene.frame.size.height)
            self.titleLabel.fontSize = 50
            self.directionLabel.fontSize = 22
            self.directionLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) * 0.11)
            self.gameCenterButton.xScale = 1.0
            self.gameCenterButton.yScale = 1.0
            self.gameCenterButton.position = CGPointMake(CGRectGetMaxX(scene.frame) * 0.02, CGRectGetMaxY(scene.frame) * (-0.015))
        } else {
            self.titleLabel.fontSize = 40
            self.directionLabel.fontSize = 24
            self.gameCenterButton.position = CGPointMake(CGRectGetMaxX(scene.frame) * (-0.03), CGRectGetMaxY(scene.frame) * (-0.03))
            self.directionLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) * 0.13)
        }
        
        self.addChild(self.titleLabel)
        self.addChild(self.directionLabel)
        self.addChild(self.gameCenterButton)
    }

    func turnSoundOnOff(switchButton : SoundButtonSwitch) {
        if switchButton == SoundButtonSwitch.On {
            println("SoundButtonSwitch.On")
            self.soundOffButton.removeFromParent()
            self.addChild(self.soundOnButton)
        } else {
            println("SoundButtonSwitch.Off")
            self.soundOnButton.removeFromParent()
            self.addChild(self.soundOffButton)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}