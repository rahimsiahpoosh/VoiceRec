//
//  TimeService.swift
//  SoundRec
//
//  Created by Rahim Siahpoosh on 2018-08-02.
//  Copyright © 2018 Rahim Siahpoosh. All rights reserved.
//

import Foundation
import AudioToolbox
import AVFoundation
import UIKit

class TimeService {
    
    func showTime(audioRecorder: AVAudioRecorder, timeLabel: UILabel, soundLevelImg: UIImageView) {
        let time = audioRecorder.currentTime
        let seconds = Int(time) % 60
        let minutes = (Int(time) / 60) % 60
        
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        audioRecorder.updateMeters()
        let level = -2*audioRecorder.averagePower(forChannel: 0)
        
        let frameSize = soundLevelImg.frame.size
        let barWidth = frameSize.width
        let barHeight = frameSize.height / 20
        UIGraphicsBeginImageContextWithOptions(frameSize, false, 0.0)
        if let ctx = UIGraphicsGetCurrentContext() {
            for i in 0..<20 {
                if 10 * i > Int(level) {
                    ctx.setFillColor(UIColor.green.cgColor)
                } else {
                    ctx.setFillColor(UIColor.black.cgColor)
                }
                ctx.addRect(CGRect(x: 0, y: CGFloat(i) * barHeight, width: barWidth, height: CGFloat(0.7) * barHeight))
                ctx.fillPath()
            }
            soundLevelImg.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    func showPlayTime(audioPlayer: AVAudioPlayer, timeLabel: UILabel, slider: UISlider) {
        let time = audioPlayer.currentTime
        let seconds = Int(time) % 60
        let minutes = (Int(time) / 60) % 60
        
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        slider.value = Float(time)
    }
    
    func resetTime(timer: Timer, timeLabel: UILabel) {
        let timer = timer
        timer.invalidate()
        let seconds = 0
        let minutes = 0
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
    }
}
