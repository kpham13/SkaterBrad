//
//  NewGrameNode.swift
//  SkaterBrad
//
//  Created by Sam Wong on 30/10/2014.
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
    var playButton: SKSpriteNode!
    var soundOnButton: SKSpriteNode!
    var soundOffButton: SKSpriteNode!
    
    init(scene: SKScene, playSound: Bool) {
        super.init()

        self.titleLabel = SKLabelNode(text: "SkaterBrad")
        self.titleLabel.fontName = "Chalkduster"
        self.titleLabel.fontSize = 40
        self.titleLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) - 90)
        self.titleLabel.zPosition = 5
        self.addChild(self.titleLabel)
        
        self.titleLabel = SKLabelNode(text: "Swipe to jump")
        self.titleLabel.fontName = "Chalkduster"
        self.titleLabel.fontSize = 28
        self.titleLabel.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMaxY(scene.frame) - 250)
        self.titleLabel.zPosition = 5
        self.addChild(self.titleLabel)
        
        // new game button
        self.playButton = SKSpriteNode(imageNamed: "playNow.png")
        self.playButton.name = "PlayNow"
        self.playButton.position = CGPointMake(CGRectGetMidX(scene.frame), CGRectGetMidY(scene.frame))
        self.playButton.zPosition = 5
        self.addChild(self.playButton)
        
        // sound on button
        self.soundOnButton = SKSpriteNode(imageNamed: "SoundOn")
        self.soundOnButton.position = CGPoint(x: CGRectGetMaxX(scene.frame) - self.soundOnButton.frame.width / 2, y: CGRectGetMaxY(scene.frame) - self.soundOnButton.frame.height / 2)
        self.soundOnButton?.name = "SoundOn"
        self.soundOnButton.xScale = 0.40
        self.soundOnButton.yScale = 0.40
        self.soundOnButton.zPosition = 2.0
        
        //
        // sound off button
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