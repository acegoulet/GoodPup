//
//  ViewController.swift
//  Let'sBeFrank
//
//  Created by Ace Goulet on 8/31/18.
//  Copyright © 2018 AceGoulet, LLC. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var defaultImage: UIImageView!
    @IBOutlet weak var goodDogView: UIView!
    @IBOutlet weak var toolBarSaveSpace: UIBarButtonItem!
    @IBOutlet weak var toolBarSaveButton: UIBarButtonItem!
    @IBOutlet weak var goodPupWatermark: UIImageView!
    @IBOutlet weak var loadBG: UIImageView!
    @IBOutlet weak var errorUIView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let navBarLogo = UIImage(named: "GoodPup")
    
    let imagePickerCamera = UIImagePickerController()
    let imagePickerLibrary = UIImagePickerController()
    var resultLabel = ""
    var positiveChecker = false
    
    let defaults = UserDefaults.standard
    
    var dogBreeds = [String]()
    
    var positiveLabels = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let dogBreedsDefaults = defaults.array(forKey: "DogBreeds") as? [String] {
            dogBreeds = dogBreedsDefaults
        } else {
            fatalError("Could not fetch breeds")
        }
        
        if let positiveResponsesDefaults = defaults.array(forKey: "PositiveResponses") as? [String] {
            positiveLabels = positiveResponsesDefaults
        } else {
            fatalError("Could not fetch postive responses")
        }
        
        imagePickerCamera.delegate = self
        imagePickerCamera.sourceType = .camera
        imagePickerCamera.allowsEditing = false
        
        imagePickerLibrary.delegate = self
        imagePickerLibrary.sourceType = .photoLibrary
        imagePickerLibrary.allowsEditing = false
        
        starView.isHidden = true
        starLabel.text = ""
        goodPupWatermark.isHidden = true
        
        errorUIView.isHidden = true
        
        toolBarSaveButton.isEnabled = false
        
        let navBarLogoImageView = UIImageView(image:navBarLogo)
        self.navigationItem.titleView = navBarLogoImageView
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let userPickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("unable to convert image to ciimage")
            }
            
            detect(image: ciimage)
        }
        
        imagePickerCamera.dismiss(animated: true, completion: nil)
        imagePickerLibrary.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else {
            fatalError("Loading coreml model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("model failed to process image")
            }
            //print(results)
            if let firstResult = results.first {
                print("ml result: \(firstResult.identifier)")
                
                
                self.positiveChecker = false
                self.errorUIView.isHidden = true
                self.starView.isHidden = true
                self.starLabel.text = ""
                self.defaultImage.isHidden = true
                self.toolBarSaveButton.isEnabled = false
                self.goodPupWatermark.isHidden = true
                self.loadBG.isHidden = true
                for breed in self.dogBreeds {
                    //print("array item: \(breed.lowercased())")
                    if firstResult.identifier.lowercased().contains(breed.lowercased()) {
                        self.resultLabel = self.positiveLabels[Int(arc4random_uniform(UInt32(self.positiveLabels.count)))]
                        self.starView.isHidden = false
                        self.starLabel.text = self.resultLabel
                        self.positiveChecker = true
                        self.toolBarSaveButton.isEnabled = true
                        self.goodPupWatermark.isHidden = false
                        break
                    }
                }
                if self.positiveChecker == false {
                    var resultString = firstResult.identifier
                    guard let resultStringFirstWord = resultString.components(separatedBy: " ").first else { fatalError("cannot find first word in result string") }
                    if let range = resultString.range(of: "\(resultStringFirstWord) ") {
                        resultString.removeSubrange(range)
                    }
                    guard let truncatedResultString = resultString.components(separatedBy: ",").first else { fatalError("Couldn't truncate result string") }
                    
                    self.errorUIView.isHidden = false
                    self.errorLabel.text = "That's not a dog. Is that a \(truncatedResultString)?!"
                }
                
            }
            else {
                print("no first result")
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePickerCamera, animated: true, completion: nil)
    }
    @IBAction func libraryTapped(_ sender: UIBarButtonItem) {
        present(imagePickerLibrary, animated: true, completion: nil)
    }
    
    //MARK: - Star Badge Manipulations
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        if let view = recognizer.view {
            if(view.center.x + translation.x < goodDogView.bounds.maxX && view.center.x + translation.x > goodDogView.bounds.minX && view.center.y + translation.y < goodDogView.bounds.maxY && view.center.y + translation.y > goodDogView.bounds.minY){
                view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
            }
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    
    
    //MARK: - Saving Image
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        let renderer = UIGraphicsImageRenderer(size: goodDogView.bounds.size)
        let image = renderer.image { ctx in
            goodDogView.drawHierarchy(in: goodDogView.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved", message: "Your very good dog has been saved to your photos!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
