//
//  SoundController.swift
//  MalingAdventure
//
//  Created by Nadhif Rahman Alfan on 25/06/24.
//

import Foundation
import AVFoundation

class SoundManager {
    
    static var audioPlayer: AVAudioPlayer?
    static var audioPlayerBackground: AVAudioPlayer?
    
    static func playClick(){
        if let url = Bundle.main.url(forResource: "click", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        } else {
            print("Error: file not found")
        }
    }
    
    static func play(_ soundName: String){
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        } else {
            print("Error: file not found")
        }
    }
    
    static func playBackground(){
        if let url = Bundle.main.url(forResource: "bgmGamePlay", withExtension: "mp3") {
            do {
                audioPlayerBackground = try AVAudioPlayer(contentsOf: url)
                audioPlayerBackground?.numberOfLoops = -1
                audioPlayerBackground?.volume = 0.3
                audioPlayerBackground?.play()
                
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        } else {
            print("Error: file not found")
        }
    }
    
    static func playEnding(){
            if let url = Bundle.main.url(forResource: "bgmEnding", withExtension: "mp3") {
                do {
                    audioPlayerBackground = try AVAudioPlayer(contentsOf: url)
                    audioPlayerBackground?.numberOfLoops = -1
                    audioPlayerBackground?.volume = 0.0  // Start with volume 0
                    audioPlayerBackground?.play()
                    
                    fadeInBackground()
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                print("Error: file not found")
            }
        }
        
    static func fadeInBackground() {
        guard let audioPlayerBackground = audioPlayerBackground else { return }
        
        let fadeDuration: TimeInterval = 3.0  // Duration of the fade-in in seconds
        let fadeSteps: TimeInterval = 0.1  // Interval between volume increments
        let targetVolume: Float = 0.3  // Final volume after fade-in
        
        let volumeIncrement = targetVolume / Float(fadeDuration / fadeSteps)
        
        Timer.scheduledTimer(withTimeInterval: fadeSteps, repeats: true) { timer in
            if audioPlayerBackground.volume < targetVolume {
                audioPlayerBackground.volume += volumeIncrement
                if audioPlayerBackground.volume >= targetVolume {
                    audioPlayerBackground.volume = targetVolume
                    timer.invalidate()
                }
            } else {
                timer.invalidate()
            }
        }
    }
        
    static func fadeOutBackground() {
        guard let audioPlayerBackground = audioPlayerBackground else { return }
        
        let fadeDuration: TimeInterval = 3.0  // Duration of the fade-out in seconds
        let fadeSteps: TimeInterval = 0.1  // Interval between volume decrements
        let initialVolume = audioPlayerBackground.volume
        let volumeDecrement = initialVolume / Float(fadeDuration / fadeSteps)
        
        Timer.scheduledTimer(withTimeInterval: fadeSteps, repeats: true) { timer in
            if audioPlayerBackground.volume > 0 {
                audioPlayerBackground.volume -= volumeDecrement
                if audioPlayerBackground.volume <= 0 {
                    audioPlayerBackground.volume = 0
                    audioPlayerBackground.stop()
                    timer.invalidate()
                }
            } else {
                timer.invalidate()
            }
        }
    }
        
    static func stopBackground(){
        fadeOutBackground()
    }
    
}
