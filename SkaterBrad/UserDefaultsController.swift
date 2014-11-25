//
//  UserDefaultsController.swift
//  SkaterBrad
//
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import Foundation

class UserDefaultsController {
    
    // High Score [KP]
    func highScoreCheck(scene: GameScene) {
        var currentHighScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        
        if scene.score > currentHighScore {
            NSUserDefaults.standardUserDefaults().setInteger(scene.score, forKey: "highscore")
            NSUserDefaults.standardUserDefaults().synchronize()
            scene.highScore = scene.score
            scene.highScoreText.text = "High Score: \(scene.highScore)"
        }
    }
    
}