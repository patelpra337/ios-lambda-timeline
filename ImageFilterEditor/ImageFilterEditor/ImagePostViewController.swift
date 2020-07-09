//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by patelpra on 7/8/20.
//  Copyright © 2020 Crus Technologies. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {
    
    private let context = CIContext()
    
    private let invertColorsFilter = CIFilter.colorInvert()
    private let vignetteFilter = CIFilter.vignette()
    private let lineOverlayFilter = CIFilter.lineOverlay()
    private let kaleidoscopeFilter = CIFilter.kaleidoscope()
    private let perspectiveFilter = CIFilter.perspectiveTransform()
    
    var orignalImage: UIImage? {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
    }
    

}
