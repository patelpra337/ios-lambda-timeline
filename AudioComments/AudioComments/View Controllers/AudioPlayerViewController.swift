//
//  AudioPlayerViewController.swift
//  AudioComments
//
//  Created by patelpra on 7/12/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioPlayerControllerDelegate: class {
    func updateAudioPlayerViews()
}

class AudioPlayerViewController: UIViewController {
    
    // MARK: - Properties
    
    private var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }
    
    var elapsedTime: TimeInterval { audioPlayer?.currentTime ?? 0 }
    var duration: TimeInterval { audioPlayer?.duration ?? 0 }
    var timeRemaining: TimeInterval { duration.rounded() - elapsedTime }
    
    var audioURL: URL? {
        didSet {
            guard let audioURL = audioURL else { return }
            
            loadAudio(url: audioURL)
            updateViews()
        }
    }
    
    weak var delegate: AudioPlayerControllerDelegate?
    
    func loadAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            preconditionFailure("Failure to load audio file: \(error)")
        }
    }
    
    // MARK: - IBActions
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func updateCurrentTime(time: TimeInterval) {
        var shouldResumePlaying = false
        
        if isPlaying {
            pause()
            shouldResumePlaying = true
        }
        
        audioPlayer?.currentTime = time
        
        if shouldResumePlaying {
            play()
        } else {
            updateViews()
        }
    }
    
    func rewindCurrentTimeBy(seconds: TimeInterval) {
        let newTime = elapsedTime - seconds
        
        if newTime < 0 {
            updateCurrentTime(time: 0)
        } else {
            updateCurrentTime(time: newTime)
        }
        play()
    }
    
    func skipForwardCurrentTimeBy(seconds: TimeInterval) {
        let newTime = elapsedTime + seconds
        
        if newTime > duration {
            updateCurrentTime(time: duration)
        } else {
            updateCurrentTime(time: newTime)
        }
        play()
    }
    
    func deleteRecording(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Could not delete recording with URL: \(url)")
        }
    }
    
    private func updateViews() {
        delegate?.updateAudioPlayerViews()
    }
    
    // MARK: - Timer
    
    private weak var timer: Timer?
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
            
            if let audioPlayer = self.audioPlayer,
                self.isPlaying == true {
                
                audioPlayer.updateMeters()
            }
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Playback
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    private func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    private func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            updateViews()
            startTimer()
        } catch {
            print("Cannot play audio: \(error)") // TODO: display an alert to the user here
        }
    }
    
    private func pause() {
        audioPlayer?.pause()
        updateViews()
        cancelTimer()
    }
    
    private func stop() {
        audioPlayer?.stop()
        updateViews()
        cancelTimer()
    }
}


// MARK: - AVAudioPlayerDelegate

extension AudioPlayerController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
        cancelTimer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}
