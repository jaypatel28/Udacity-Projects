//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Jay Patel on 10/20/15.
//  Copyright © 2015 MEAMobile. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    @IBOutlet weak var stopSound: UIButton!
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = try! AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
        
        stopSound.hidden = true

        // Do any additional setup after loading the view.
    }
    
    func resetAudio(){
        stopSound.hidden = false
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAudioWithRate(rate: Float, currentTime: NSTimeInterval = 0.0) {
        resetAudio()
        audioPlayer.rate = rate
        audioPlayer.currentTime = currentTime
        audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        
        resetAudio()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        
        audioPlayerNode.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowSound(sender: UIButton) {
        playAudioWithRate(0.5)
    }
    @IBAction func playFastSound(sender: UIButton) {

        playAudioWithRate(1.5)
    }
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    @IBAction func palyDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func stopSound(sender: UIButton) {
        resetAudio()
        stopSound.hidden = true
    }

}
