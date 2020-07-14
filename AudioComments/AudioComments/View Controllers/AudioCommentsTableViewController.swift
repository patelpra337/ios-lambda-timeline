//
//  AudioCommentsTableViewController.swift
//  AudioComments
//
//  Created by patelpra on 7/12/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentsTableViewController: UIViewController {
    
    var audioComments = [AudioComment]()
    
    var audioController = AudioPlayerViewController() {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
