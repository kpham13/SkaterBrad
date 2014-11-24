//
//  MusicNode.swift
//  SkaterBrad
//
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class SoundNode: SKNode {
    
    var audioPlayer : AVAudioPlayer! = nil
    var isSoundOn = true
    let backgoundMusicFile = "music"
    var avAudioSession : AVAudioSession!
    var musicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("music", ofType: "mp3")!)
    
    init(isSoundOn : Bool) {
        super.init()
        
        self.avAudioSession = AVAudioSession.sharedInstance()
        self.avAudioSession.setCategory(AVAudioSessionCategoryPlayback, error: nil)
        self.avAudioSession.setActive(true, error: nil)
        self.avAudioSession.setCategory(AVAudioSessionCategoryAmbient, error: nil)
        
        self.audioPlayer = AVAudioPlayer()
        //var musicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(self.backgoundMusicFile, ofType: "mp3")!)
        
        self.audioPlayer = AVAudioPlayer(contentsOfURL: musicURL, error: nil)
        self.audioPlayer.numberOfLoops = 100 // Continuous play of background music [Kevin/Tuan]
        self.audioPlayer.volume = 0.1 // Adjusts background music volume [Kevin]
        
        self.isSoundOn = isSoundOn
        
        self.playMusic(isSoundOn)
        
//        if self.isSoundOn {
//            self.audioPlayer.prepareToPlay()
//            self.audioPlayer.play()
//        }
    }
    
    func playMusic(isSoundOn : Bool) {
        var error : NSError?
        self.audioPlayer = AVAudioPlayer(contentsOfURL: musicURL, error: nil)
        
        if error != nil {
            println(error)
        } else {
            if isSoundOn {
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.numberOfLoops = -1
                self.audioPlayer.volume = 0.25
                self.audioPlayer?.play()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}