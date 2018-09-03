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
    
    var starBadgePanGesture = UIPanGestureRecognizer()
    var starViewStartHeight : CGFloat = 0.0
    var starViewStartWidth : CGFloat = 0.0
    var starViewStartPoint = CGPoint(x: 0.0, y: 0.0)
    var lastRotation: CGFloat = 0
    
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
        
        //gestures and manipulations with Star badge
        starBadgePanGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.draggedView(_:)))
        starView.isUserInteractionEnabled = true
        starView.addGestureRecognizer(starBadgePanGesture)
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotatedView(_:)))
        starView.addGestureRecognizer(rotate)
        
        errorUIView.isHidden = true
        
        toolBarSaveButton.isEnabled = false
        
        let navBarLogoImageView = UIImageView(image:navBarLogo)
        self.navigationItem.titleView = navBarLogoImageView
        
        //Get initial position and size of starview
        starViewStartHeight = starView.frame.size.height
        starViewStartWidth = starView.frame.size.width
        starViewStartPoint = CGPoint(x: (starView.center.x - (starViewStartWidth / 5)), y: starView.center.y)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
                //print("ml result: \(firstResult.identifier)")
                
                //reset position of star badge
                self.starView.center = self.starViewStartPoint
                
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
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubview(toFront: starView)
        let translation = sender.translation(in: self.view)
        if(starView.center.x + translation.x < goodDogView.bounds.maxX && starView.center.x + translation.x > goodDogView.bounds.minX && starView.center.y + translation.y < goodDogView.bounds.maxY && starView.center.y + translation.y > goodDogView.bounds.minY){
            starView.center = CGPoint(x: starView.center.x + translation.x, y: starView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
        var originalRotation = CGFloat()
        if sender.state == .began {
            print("begin")
            sender.rotation = lastRotation
            originalRotation = sender.rotation
        } else if sender.state == .changed {
            print("changing")
            let newRotation = sender.rotation + originalRotation
            sender.view?.transform = CGAffineTransform(rotationAngle: newRotation)
        } else if sender.state == .ended {
            print("end")
            lastRotation = sender.rotation
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

