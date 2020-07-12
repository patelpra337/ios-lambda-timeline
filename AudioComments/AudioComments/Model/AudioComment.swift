//
//  AudioComment.swift
//  AudioComments
//
//  Created by patelpra on 7/12/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import Foundation

struct AudioComment {
    
    var title: String
    var duration: TimeInterval
    var url: URL?
    var timestamp: Date = Date()
    
    init(title: String, duration: TimeInterval, url: URL? = nil) {
        self.title = title
        self.duration = duration
        self.url = url
    }
}
