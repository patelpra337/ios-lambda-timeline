//
//  PostCollectionViewCell.swift
//  VideoPosts
//
//  Created by patelpra on 7/15/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class PostCollectionViewCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    private var player: AVPlayer?
    private var isPlaying: Bool = false
    
    @IBOutlet weak var moviePlayerView: VideoPlayerView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        player = nil
        post = nil
        isPlaying = false
        imageView?.image = nil
        titleLabel?.text = ""
        authorLabel?.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
        setupMoviePlayerView()
    }
    
    func updateViews() {
        guard let post = post else { return }
        
        titleLabel?.text = post.title
        authorLabel?.text = post.author.displayName
        
        player = AVPlayer(url: post.mediaURL)
        moviePlayerView?.player = player
        moviePlayerView?.videoPlayerLayer.videoGravity = .resizeAspectFill
        player?.actionAtItemEnd = .pause
        
        //imageView.image = image
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView?.layer.cornerRadius = 8
        labelBackgroundView?.clipsToBounds = true
    }
    
    func setupMoviePlayerView() {
        guard let moviePlayerView = moviePlayerView else { return }
        let tapGesture = UITapGestureRecognizer(target: self.moviePlayerView, action: #selector(togglePlayMovie))
        moviePlayerView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem,
                                               queue: .main) { [weak self] _ in
                                                self?.resetMovie()
        }
    }
    
    private func resetMovie() {
        guard let player = player else { return }
        
        player.pause()
        player.seek(to: .zero)
        isPlaying = false
    }
    
    @objc private func togglePlayMovie() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
}
