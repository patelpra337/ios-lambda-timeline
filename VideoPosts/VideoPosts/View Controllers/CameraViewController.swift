//
//  CameraViewController.swift
//  VideoPosts
//
//  Created by patelpra on 7/14/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import AVKit
import MapKit

protocol CameraViewControllerDelegate: class {
    func didSaveVideo(at url: URL, withTitle title: String, location: CLLocationCoordinate2D?)
}

class CameraViewController: UIViewController {

    // MARK: - Properties
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    private var player: AVPlayer!
    private var videoURL: URL? = nil
    weak var delegate: CameraViewControllerDelegate?
    private let locationManager = CLLocationManager()
    private var location: CLLocationCoordinate2D?
    
    // MARK: - IBOutlets
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    @IBOutlet weak var moviePlayerView: VideoPlayerView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    
    // MARK: - IBActions
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            navigationController?.setNavigationBarHidden(true, animated: false)
            videoURL = newRecordingURL()
            fileOutput.startRecording(to: videoURL!, recordingDelegate: self)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        dismissMoviePlayerViews()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text,
            !title.isEmpty,
            let url = videoURL else { return }
        
        delegate?.didSaveVideo(at: url, withTitle: title, location: location)
        dismissMoviePlayerViews()
    }
    
    private func dismissMoviePlayerViews() {
        moviePlayerView.player?.pause()
        moviePlayerView.player = nil
        titleTextField.text = nil
        view.endEditing(true)
        navigationController?.popToRootViewController(animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        cameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
        setupCamera()
        
        moviePlayerView.videoPlayerLayer.videoGravity = .resizeAspectFill
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    // MARK: - Video Playback
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        moviePlayerView.player = player

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player.currentItem,
                                               queue: .main) { [weak self] _ in
                                                self?.replayMovie()
        }
        player.play()
        
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func replayMovie() {
        guard let player = player else { return }
        
        player.seek(to: .zero)
        player.play()
    }
    
    // MARK: - Setup Methods
    
    private func setupCamera() {
        let camera = bestCamera()
        let microphone = bestMicrophone()
        
        captureSession.beginConfiguration()
        
        // MARK: - Begin Configuring Capture Session
        
        // Add input: Video
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            preconditionFailure("Can't create an input from the camera, but we should do something better than crashing!")
        }
        
        guard captureSession.canAddInput(cameraInput) else {
            preconditionFailure("This session can't handle this type of input: \(cameraInput)")
        }
        
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Add input: Audio
        guard let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            preconditionFailure("Can't create an input from the microphone, but we should do something better than crashing!")
        }
        
        guard captureSession.canAddInput(microphoneInput) else {
            preconditionFailure("This session can't handle this type of input: \(microphoneInput)")
        }
        
        captureSession.addInput(microphoneInput)
        
        // Add output: Recording to disk
        guard captureSession.canAddOutput(fileOutput) else {
            preconditionFailure("This session can't handle this type of output: \(fileOutput)")
        }
        
        captureSession.addOutput(fileOutput)
        
        // MARK: - End Configuring Capture Session
        
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession // Live preview
    }
    
    private func bestCamera() -> AVCaptureDevice {
        
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        
        // All iPhones have a wide angle camera (front + back)
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        // TODO: Add a button to toggle front/back camera
        
        preconditionFailure("No cameras on device match the specs that we need (or you're running this on a Simulator which isn't supported)")
    }
    
    private func bestMicrophone() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        
        preconditionFailure("No microphones on device match the specs that we need")
    }
    
    // MARK: - Save video to disk
    
    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    // MARK: - Animations
    
    private func animateViewsOnScreen() {
        moviePlayerView.isHidden = false
        cameraView.isHidden = true
        
        UIView.animate(withDuration: 1.0,
                       delay: 0.25,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        
            self.navigationBarTopConstraint.constant = 0
            self.view.layoutIfNeeded()
                        
        }, completion: nil)
    }
    
    // Uncomment this function if you would like to animate the views back up and
    // off the top of the screen
    /*
    private func animateViewsOffScreen() {
        moviePlayerView.isHidden = true
        cameraView.isHidden = false
        
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseIn,
                       animations: {
                        
            self.navigationBarTopConstraint.constant = -162
            self.view.layoutIfNeeded()
                        
        }, completion: nil)
    }
 */
}

// MARK: - AVCaptureFileOutput Recording Delegate

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        
        print("Video URL: \(outputFileURL)")
        updateViews()
        
        locationManager.requestLocation()
        location = locationManager.location?.coordinate
        
        playMovie(url: outputFileURL)
        animateViewsOnScreen()
    }
}

extension CameraViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            self.location = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find users's location: \(error.localizedDescription)")
    }
}

