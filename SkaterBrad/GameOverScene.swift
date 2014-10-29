//
//  GameOverScene.swift
//  SkaterBrad
//
//  Created by Sam Wong on 28/10/2014.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import SpriteKit

class GameOverScene : SKScene {
    var won = false

    init(size: CGSize, won:Bool) {
        
        super.init(size: size)

        backgroundColor = SKColor.whiteColor()
        
        var message = won ? "You Won!" : "You Lose :["
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(3.0),
            SKAction.runBlock() {
                // 5
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func didMoveToView(view: SKView) {
//        var background : SKSpriteNode
//        if (self.won) {
//            background = SKSpriteNode(imageNamed: "YouWin.png")
//            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1),
//                SKAction.playSoundFileNamed("win.wav", waitForCompletion: false)]))
//        } else {
//            background = SKSpriteNode(imageNamed: "YouLose.png")
//            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1),
//                SKAction.playSoundFileNamed("lose.wav", waitForCompletion: false)]))
//        }
//
//        background.position = CGPointMake(size.width / 2, size.height / 2)
//        self.addChild(background)
//    }

}
