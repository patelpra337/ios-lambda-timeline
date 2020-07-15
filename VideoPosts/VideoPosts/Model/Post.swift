//
//  Post.swift
//  VideoPosts
//
//  Created by patelpra on 7/14/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit

struct Author: Equatable {
    let uid: String = UUID().uuidString
    let displayName: String
    
    static let crus = Author(displayName: "crus")
}

class Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
    
    var title: String
    var mediaURL: URL
    var ratio: CGFloat?
    var author: Author
    var timestamp: Date
    
    init(title: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author = Author.crus, timestamp: Date = Date()) {
        self.title = title
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.author = author
        self.timestamp = timestamp
    }
}
