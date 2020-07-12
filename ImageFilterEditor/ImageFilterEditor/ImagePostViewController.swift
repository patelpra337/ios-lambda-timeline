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
    @IBOutlet var exposureAdjustSlider: UISlider!
    @IBOutlet var unsharpMaskSlider: UISlider!
    @IBOutlet var sharpLumianceSlider: UISlider!
    
    
    private let context = CIContext()
    
    private let invertColorsFilter = CIFilter.colorInvert()
    private let vignetteFilter = CIFilter.vignette()
    private let unsharpMaskFilter = CIFilter.unsharpMask()
    private let exposureAdjustFilter = CIFilter.exposureAdjust()
    private let sharpLumianceFilter = CIFilter.sharpenLuminance()
    
    
    var orignalImage: UIImage? {
        didSet {
            guard let orignalImage = orignalImage else {
                scaledImage = nil
                return
            }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width*scale,
                                height: scaledSize.height*scale)
            
            guard let scaledUIImage = orignalImage.imageByScaling(toSize: scaledSize) else {
                scaledImage = nil
                return
            }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }
    
    var scaledImage: CIImage? {
        didSet {
            updateImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orignalImage = imageView.image
    }
    
    @IBAction func photosButton(_ sender: Any) {
        presentImagePickerController()
    }
    
    private func image(byFiltering inputImage: CIImage) -> UIImage? {
        
        var outputImage = inputImage
             

        if invertColors.isOn {
            invertColorsFilter.inputImage = outputImage
            guard let filteredImage = invertColorsFilter.outputImage else {
                return orignalImage! }
            outputImage = filteredImage
        }
        
        if vignetteSlider.value > 0 {
            vignetteFilter.inputImage = outputImage
            vignetteFilter.radius = vignetteSlider.value * 100
            vignetteFilter.intensity = vignetteSlider.value * 2
            if let filteredImage = vignetteFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        if exposureAdjustSlider.value > 0 {
            exposureAdjustFilter.inputImage = outputImage
            exposureAdjustFilter.ev = exposureAdjustSlider.value * 3
            if let filteredImage = exposureAdjustFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        if unsharpMaskSlider.value > 0 {
            unsharpMaskFilter.inputImage = outputImage
            unsharpMaskFilter.intensity = unsharpMaskSlider.value * 9
            if let filteredImage = unsharpMaskFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        if sharpLumianceSlider.value > 0 {
            sharpLumianceFilter.inputImage = outputImage
            sharpLumianceFilter.sharpness = sharpLumianceSlider.value * 4
            if let filteredImage = sharpLumianceFilter.outputImage {
                outputImage = filteredImage
            }
        }
        
        guard let renderedCGImage = context.createCGImage(outputImage, from: inputImage.extent) else { return  nil }//orignalImage! }
        
        return UIImage(cgImage: renderedCGImage)
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
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
    
    
    @IBAction func invertColorSwitchChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func vignetteChanged(_ sender: Any) {
        updateImage()
    }
    
    @IBAction func exposureAdjustChanged(_ sender: Any) {
        updateImage()
    }
    @IBAction func unsharpMaskChanged(_ sender: Any) {
        updateImage()
    }
    @IBAction func sharpLumianceChanged(_ sender: Any) {
        updateImage()
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
