//
//  PostLocationViewController.swift
//  VideoPosts
//
//  Created by patelpra on 7/16/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class PostLocationViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    
    var posts: [Post] = []
    
    var postArea: [Post] = [] {
        didSet {
            let oldPosts = Set(oldValue)
            let newPosts = Set(posts)
            
            let addedPosts = Array(newPosts.subtracting(oldPosts))
            let removedPosts = Array(oldPosts.subtracting(newPosts))
            
            mapView.removeAnnotations(removedPosts)
            mapView.addAnnotations(addedPosts)
        }
    }
    
    private var isCurrentlyFetchingPosts = false
    private var shouldRequestPostsAgain = false
    private var userTrackingButon: MKUserTrackingButton!
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        userTrackingButon = MKUserTrackingButton(mapView: mapView)
        userTrackingButon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButon)
        
        NSLayoutConstraint.activate([
            userTrackingButon.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            mapView.bottomAnchor.constraint(equalTo: userTrackingButon.bottomAnchor, constant: 20)
        ])
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: ReuseIdentifiers.annotationReuseIdentifier)
        
        fetchPosts()

    }
    
    private func fetchPosts() {
        guard !isCurrentlyFetchingPosts else {
            shouldRequestPostsAgain = true
            return
        }
        
        isCurrentlyFetchingPosts = true
        
        let visibleRegion = mapView.visibleMapRect
        
        fetchPosts(in: visibleRegion) { posts in
            self.isCurrentlyFetchingPosts = false
            
            defer {
                if self.shouldRequestPostsAgain {
                    self.shouldRequestPostsAgain = false
                    self.fetchPosts()
                }
            }
            
            self.posts = posts
        }
    }
    
    func fetchPosts(in region: MKMapRect? = nil, completion: @escaping ([Post]) -> Void) {
        guard let region = region else {
            completion(self.posts)
            return
        }
        
        let postArea = posts.filter { region.contains(MKMapPoint($0.location)) }
        self.isCurrentlyFetchingPosts = false
        
        defer {
            if self.shouldRequestPostsAgain {
                self.shouldRequestPostsAgain = false
                self.fetchPosts()
            }
        }
        
        self.posts = postArea
    }
}

extension PostLocationViewController: MKMapViewDelegate {
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        fetchPosts()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let post = annotation as? Post else { return nil }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ReuseIdentifiers.annotationReuseIdentifier, for: post) as? MKMarkerAnnotationView else {
            preconditionFailure("Missing the registered map annotation view")
        }
        
        return annotationView
    }
    
}
