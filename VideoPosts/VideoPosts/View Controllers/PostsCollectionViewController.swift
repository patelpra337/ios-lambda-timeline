//
//  PostsCollectionViewController.swift
//  VideoPosts
//
//  Created by patelpra on 7/15/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

private let reuseIdentifier = "Cell"

class PostsCollectionViewController: UICollectionViewController {
    
    var posts: [Post] = []
    
    @IBAction func addNewVideoPost(_ sender: UIBarButtonItem) {
        requestPermissionAndShowCamera()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifiers.postCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifiers.postCell, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
        
        cell.post = posts[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize(width: view.frame.width, height: view.frame.width)
        let post = posts[indexPath.row]
        
        guard let ratio = post.ratio else { return size }
        
        size.height = size.width * ratio
        
        return size
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showCamera {
            if let destinationVC = segue.destination as? CameraViewController {
                destinationVC.delegate = self
            }
        } else if segue.identifier == SegueIdentifiers.showMapView {
            if let destinationVC = segue.destination as? PostLocationViewController {
                destinationVC.posts = posts
            }
        }
    }
}

extension PostsCollectionViewController: CameraViewControllerDelegate {
    func didSaveVideo(at url: URL, postTitle: String, location: CLLocationCoordinate2D?) {
        let post = Post(posTitle: postTitle, mediaURL: url, location: location)
        posts.append(post)
        collectionView.reloadData()
    }
}

extension PostsCollectionViewController {
    
    private func requestPermissionAndShowCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined: // 1st run and the user hasn't been asked to give permission
            requestVideoPermission()
            
        case .restricted: // Parental controls, for instance, are preventing recording
            preconditionFailure("Video is disabled, please review device restrictions")
            
        case .denied: // 2nd+ run, the user didn't trust us, or they said no by accident (show how to enable)
            preconditionFailure("Tell the user they can't use the app without giving permissions via Settings > Privacy > Video")
            
        case .authorized: // 2nd+ run, the user has given the app permission to use the camera
            showCamera()
            
        @unknown default:
            preconditionFailure("A new status code for AVCaptureDevice authorization was added that we need to handle")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { isGranted in
            guard isGranted else {
                preconditionFailure("UI: Tell the user to enable permissions for Video/Camera")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: SegueIdentifiers.showCamera, sender: self)
    }
}
