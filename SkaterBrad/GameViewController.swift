//
//  GameViewController.swift
//  SkaterBrad
//
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit //1

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

//2
class GameViewController: UIViewController, GKGameCenterControllerDelegate {

    var leaderboardIdentifier : String? //7
    var gameCenterEnabled : Bool? //8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as SKView
        let myScene = GameScene(size: skView.frame.size)
        myScene.gameViewController = self //5
        self.authenticateLocalPlayer() //10
        skView.presentScene(myScene)
        
        
        // Uses GameScene.sks
        /*
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        */
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - GAME CENTER
    
    //6
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //9
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        //var localPlayer = GKLocalPlayerCustom.getLocalPlayer()
        
        localPlayer.authenticateHandler = {(viewController: UIViewController?, error: NSError?) -> Void in
            if viewController != nil {
                self.presentViewController(viewController!, animated: true, completion: nil)
            } else {
                println("Is player authenticated: \(localPlayer.authenticated)")
                if localPlayer.authenticated {
                    println(localPlayer.authenticated)
                    self.gameCenterEnabled = true
                    
                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) -> Void in
                        if error != nil {
                            println("\(error.description)")
                        } else {
                            self.leaderboardIdentifier = leaderboardIdentifier
                        }
                    })
                } else {
                    self.gameCenterEnabled = false
                }
            }
        }
    }
    
    //11
    func reportScoreToGameCenter(intForScore: Int64, forLeaderboard: String) {
        var score = GKScore(leaderboardIdentifier: forLeaderboard)
        score.value = intForScore
        
        GKScore.reportScores([score], withCompletionHandler: { (error) -> Void in
            if error != nil {
                println("\(error.description)")
            }
        })
    }
    
    //13
    func showLeaderboardAndAchievements(shouldShowLeaderboard: Bool) {
        var gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        
        if shouldShowLeaderboard == true {
            gameCenterViewController.viewState = GKGameCenterViewControllerState.Leaderboards
            gameCenterViewController.leaderboardIdentifier = self.leaderboardIdentifier
        } else {
            gameCenterViewController.viewState = GKGameCenterViewControllerState.Achievements
        }
        
        self.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
}
