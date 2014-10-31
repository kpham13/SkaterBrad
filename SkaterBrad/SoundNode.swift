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

class SoundNode : SKNode {
    
    var audioPlayer : AVAudioPlayer! = nil
    let backgoundMusicFile = "bgMusic"
    
    override init() {
        super.init()
        self.audioPlayer = AVAudioPlayer()
        var musicURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(self.backgoundMusicFile, ofType: "mp3")!)
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        self.audioPlayer = AVAudioPlayer(contentsOfURL: musicURL, error: nil)
        self.audioPlayer.prepareToPlay()
        self.audioPlayer.play()
        self.audioPlayer.numberOfLoops = 100
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}