//
//  Post.swift
//  VideoPosts
//
//  Created by patelpra on 7/14/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import MapKit

class Post: NSObject {
    
    var postTitle: String
    var mediaURL: URL
    var ratio: CGFloat?
    var author: Author
    var timestamp: Date
    var location: CLLocationCoordinate2D

    init(postTitle: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author = Author.crus, timestamp: Date = Date(), location: CLLocationCoordinate2D? = nil) {
        self.postTitle = postTitle
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.author = author
        self.timestamp = timestamp
        self.location = location ?? Locations.defaultLocation
        
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
}
    
struct Author: Equatable {
    let uid: String = UUID().uuidString
    let displayName: String
            
    static let crus = Author(displayName: "crus")
}

extension Post: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        location
    }
    
    var title: String? {
        postTitle
    }
    
    var subtitle: String? {
        "Author: \(author.displayName)"
    }
}

extension Post {
    
}
