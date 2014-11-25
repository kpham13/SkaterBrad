//
//  MusicNode.swift
//  SkaterBrad
//
//  Created by Sam Wong on 30/10/2014.
//  Copyright (c) 2014 Mother Functions. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class SoundNode: SKNode {
    
    var audioPlayer : AVAudioPlayer! = nil
    var playSound = true
    let backgoundMusicFile = "music"
    
    init(playSound : Bool) {
        super.init()
        self.audioPlayer = AVAudioPlayer()
        var musicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(self.backgoundMusicFile, ofType: "mp3")!)
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        // Audio will mute when system mute.
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
        
        self.audioPlayer = AVAudioPlayer(contentsOfURL: musicURL, error: nil)
        self.audioPlayer.numberOfLoops = 100 // Continuous play of background music [Kevin/Tuan]
        self.audioPlayer.volume = 0.1 // Adjusts background music volume [Kevin]
        
        self.playSound = playSound
        
        if self.playSound {
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.play()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}