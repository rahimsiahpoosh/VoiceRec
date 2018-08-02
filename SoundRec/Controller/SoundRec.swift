//
//  ViewController.swift
//  SoundRec
//
//  Created by Rahim Siahpoosh on 2018-08-01.
//  Copyright © 2018 Rahim Siahpoosh. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class SoundRec: UIViewController {
    
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    var audioSession: AVAudioSession!
    var soundUrl: URL!
    var timer: Timer?
    var isPlaying = false
    let timeService = (UIApplication.shared.delegate as! AppDelegate).timeService
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var soundLevelImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
    }
    

    @IBAction func recordSound() {
        if audioRecorder.isRecording {
            audioRecorder.stop()
            audioRecorderDidFinishRecording(audioRecorder, successfully: true)
            timer?.invalidate()
            recordBtn.setTitle("RECORD", for: UIControlState.normal)
            recordBtn.setImage(UIImage(named: "Record"), for: UIControlState.normal)
            self.playBtn.isEnabled = true
            self.slider.isHidden = true
            do {
                try audioSession.setActive(false)
            } catch {
                print(error)
            }
        } else {
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
                soundLevelImg.isHidden = false
                recordBtn.setTitle("STOP", for: UIControlState.normal)
                recordBtn.setImage(UIImage(named: "Stop"), for: UIControlState.normal)
                self.slider.isHidden = true
                self.playBtn.isEnabled = false
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                    self.timeService.showTime(audioRecorder: self.audioRecorder, timeLabel: self.timeLabel, soundLevelImg: self.soundLevelImg)
                })
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func playSound() {
        if(isPlaying) {
            audioPlayer.stop()
            audioPlayer.currentTime = 0.0
            timeService.resetTime(timer: timer!, timeLabel: timeLabel)
            playBtn.setTitle("PLAY", for: UIControlState.normal)
            playBtn.setImage(UIImage(named: "Play"), for: UIControlState.normal)
            pauseBtn.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
            isPlaying = false
            recordBtn.isEnabled = true
            pauseBtn.isEnabled = false
            slider.isHidden = true
        } else {
            
            if !audioRecorder.isRecording {
                guard let player = try? AVAudioPlayer(contentsOf: soundUrl) else {
                    print("AVAudioPlayer fail")
                    return
                }
                audioPlayer = player
                audioPlayer?.delegate = self
                audioPlayer.play()
                slider.isHidden = false
                slider.maximumValue = Float(audioPlayer.duration)
                soundLevelImg.isHidden = true
                pauseBtn.isEnabled = true
                recordBtn.isEnabled = false
                playBtn.setTitle("STOP", for: UIControlState.normal)
                playBtn.setImage(UIImage(named: "Stop"), for: UIControlState.normal)
                isPlaying = true
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                    self.timeService.showPlayTime(audioPlayer: self.audioPlayer, timeLabel: self.timeLabel, slider: self.slider)
                })
            }
        }
    }
    
    @IBAction func pauseSound() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            pauseBtn.setTitle("RESUME", for: UIControlState.normal)
            pauseBtn.setImage(UIImage(named: "Play"), for: UIControlState.normal)
            
        } else {
            audioPlayer.play()
            pauseBtn.setTitle("PAUSE", for: UIControlState.normal)
            pauseBtn.setImage(UIImage(named: "Pause"), for: UIControlState.normal)
        }
    }
    
    @IBAction func timeSlider() {
        
        audioPlayer.stop()
        audioPlayer.currentTime = TimeInterval(slider.value)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func setupAudioSession() {
        
        pauseBtn.isEnabled = false
        playBtn.isEnabled = false
        slider.isHidden = true
        
        guard let directoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first else {
            print("Ingen dokumentmapp")
            return
        }
        
        soundUrl = directoryURL.appendingPathComponent("ljudInspelning.m4a")
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            let recorderSetting: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: soundUrl, settings: recorderSetting)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
}

extension SoundRec: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "Finish Recording", message: "Succesfully recorderd the audio", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
        }
    }
}

extension SoundRec: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playBtn.setTitle("PLAY", for: UIControlState.normal)
            playBtn.setImage(UIImage(named: "Play"), for: UIControlState.normal)
            recordBtn.isEnabled = true
            pauseBtn.isEnabled = false
            isPlaying = false
           
            
            let alertMessage = UIAlertController(title: "Finishing Playing", message: "Finish playing the recording", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertMessage, animated: true, completion: nil)
        }
    }
}

