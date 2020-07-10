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
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var invertColors: UISwitch!
    @IBOutlet var vignetteSlider: UISlider!
    @IBOutlet var sketchifySlider: UISlider!
    @IBOutlet var kaleidoscopeSlider: UISlider!
    @IBOutlet var perspectiveSwitch: UISlider!
    
    
    private let context = CIContext()
    
    private let invertColorsFilter = CIFilter.colorInvert()
    private let vignetteFilter = CIFilter.vignette()
    private let lineOverlayFilter = CIFilter.lineOverlay()
    private let kaleidoscopeFilter = CIFilter.kaleidoscope()
    private let perspectiveFilter = CIFilter.perspectiveTransform()
    
    var orignalImage: UIImage? {
        didSet {
            updateImage()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        orignalImage = imageView.image
    }
    
    @IBAction func photosButton(_ sender: UIBarButtonItem) {
        
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not avaialbe")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateImage() {
        if let orignalImage = orignalImage {
            imageView.image = orignalImage
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage {
            
        var outputImage = inputImage
        
        if invertColors.isOn {
            invertColorsFilter.inputImage = outputImage
            guard let filteredImage = invertColorsFilter.outputImage else {
                return orignalImage! }
            outputImage = filteredImage
            }
        
        if vignetteSlider.value > 0 {
            vignetteFilter.inputImage = outputImage
            vignetteFilter.radius = vignetteSlider.value * 20
            vignetteFilter.intensity = vignetteSlider.value * 2
            if let filteredImage = vignetteFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return orignalImage! }
        
        return UIImage(cgImage: renderedImage)
        
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            orignalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            orignalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
