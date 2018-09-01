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
import ChameleonFramework

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
    
    let navBarLogo = UIImage(named: "GoodPup")
    
    let imagePickerCamera = UIImagePickerController()
    let imagePickerLibrary = UIImagePickerController()
    var resultLabel = ""
    var positiveChecker = false
    let negativeLabels = ["No treat!", "NO!", "Bad!", "Not a dog!", "Ew.", "Nope.", "Try again", ":("]
    
    let positiveLabels = ["10/10 Good Dog!", "Who's a good pup? You Are!", "Good Dog!", "Good Pup deserves a treat!", "Belly rubs for the Good Dog!", "Give this good pup all the pets!", "Sweet Baby Angel!", "Extra food for this Good Dog!"]
    
    let dogBreeds = ["Affenpinscher","Afghan Hound","Airedale","Akita Inu","Malamute","Coonhound","American Eskimo Dog"," Foxhound","American Pit Bull Terrier","American Staffordshire Terrier","American Water Spaniel","Anatolian Shepherd Dog","Australian Cattle","Australian Shepherd","Australian Terrier","Azawakh","Basenji","Basset Hound","Beagle","Bearded Collie","Beauceron","Bedlington Terrier","Belgian Laekenois","Belgian Malinois","Belgian Sheepdog","Belgian Tervuren","Bergamasco","Bernese Mountain Dog","Bichon Frisé","Biewer Terrier","Black &amp; Tan Coonhound","Black Russian Terrier","Bloodhound","Bluetick Coonhound","Boerboel","Border Collie","Border Terrier","Borzoi","Boston Terrier","Bouvier des Flandres","Boxer","Briard","Brittany","Brussels Griffon","Bull Terrier","Bulldog - American","Bullmastiff","Cairn Terrier","Canaan Dog","Cane Corso","Cardigan Welsh Corgi","Cavalier King Charles","Cesky Terrier","Chesapeake Bay Retriever","Chihuahua","Chinese Crested","Chinese Shar-Pei","Chinook","Chow Chow","Cirneco dell'Etna","Clumber Spaniel","Cocker Spaniel - American","Cocker Spaniel - English","Collie","Curly-Coated Retriever","Dachshund","Dalmatian","Dandie Dinmont Terrier","Doberman Pinscher","Dogo Argentino","English Bulldog","English Foxhound","English Pointer","English Setter","English Toy Spaniel","Entlebucher Mountain Dog","Field Spaniel","Fila Brasileiro","Finnish Lapphund","Finnish Spitz","Flat Coated Retriever","French Bulldog","German Pinscher","German Shepherd","German Shorthaired Pointer","German Wirehaired Pointer","Giant Schnauzer","Glen of Imaal Terrier","Golden Retriever","Goldendoodle","Gordon Setter","Great Dane","Great Pyrenees","Greater Swiss Mountain Dog","Greyhound","Harrier","Havana Silk Dog","Havanese","Ibizan Hound","Icelandic Sheepdog","Irish Setter","Irish Terrier","Irish Water Spaniel","Irish Wolfhound","Italian Greyhound","Jack Russell Terrier","Japanese Chin","Keeshond","Kerry Blue Terrier","Komondor","Kuvasz","Labradoodle","Labrador Retriever","Lakeland Terrier","Lhasa Apso","Lowchen","Maltese","Manchester Terrier","Mastiff","Miniature Bull Terrier","Miniature Pinscher","Miniature Schnauzer","NAID Breed","Neapolitan Mastiff","Newfoundland","Norfolk Terrier","Norwegian Buhund","Norwegian Elkhound","Norwegian Lundehund","Norwich Terrier","Nova Scotia Duck Tolling","Old English Sheepdog","Otterhound","Papillon","Parson Russell Terrier","Pekingese","Pembroke Welsh Corgi","Peruvian Inca Orchid","Petit Basset Griffon Vendéen","Pharaoh Hound","Plott Hound","Polish Lowland","Pomeranian","Poodle - Standard","Poodle - Toy","Portuguese Podengo Pequeno","Portuguese Water Dog","Pug","Puli","Pumi","Pyrenean Shepherd","Rat Terrier","Redbone Coonhound","Rhodesian Ridgeback","Rottweiler","Saint Bernard","Saluki","Samoyed","Schipperke","Scottish Deerhound","Scottish Terrier","Sealyham Terrier","Shetland Sheepdog","Shiba Inu","Shih Tzu","Siberian Husky","Silky Terrier","Skye Terrier","Sloughi","Smooth Fox Terrier","Soft Coated Wheaten Terrier","Spinone Italiano","Springer Spaniel - English","Staffordshire Bull Terrier","Standard Schnauzer","Sussex Spaniel","Swedish Vallhund","Tibetan Mastiff","Tibetan Spaniel","Tibetan Terrier","Toy Fox Terrier","Treeing Walker Coonhound","Vizsla","Weimaraner","Welsh Springer Spaniel","Welsh Terrier","West Highland White Terrier","Whippet","Wire Fox Terrier","Wirehaired Pointing Griffon","Wirehaired Vizsla","Xoloitzcuintli","Yorkshire Terrier", "dog", "puppy", "pup", "poodle", "doodle", "wolf", "canine", "hound", "malamute", "terrier", "Schnauzer"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerCamera.delegate = self
        imagePickerCamera.sourceType = .camera
        imagePickerCamera.allowsEditing = false
        
        imagePickerLibrary.delegate = self
        imagePickerLibrary.sourceType = .photoLibrary
        imagePickerLibrary.allowsEditing = false
        
        starView.isHidden = true
        starLabel.text = ""
        goodPupWatermark.isHidden = true
        
        toolBarSaveSpace.isEnabled = false
        toolBarSaveButton.isEnabled = false
        
        let navBarLogoImageView = UIImageView(image:navBarLogo)
        self.navigationItem.titleView = navBarLogoImageView
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
                print("ml result: \(firstResult.identifier)")
                guard let navBar = self.navigationController?.navigationBar else { fatalError("no nav bar, bro") }
                navBar.barTintColor = UIColor(hexString: "#94A5E3")
                self.resultLabel = self.negativeLabels[Int(arc4random_uniform(UInt32(self.negativeLabels.count)))]
                self.positiveChecker = false
                self.starView.isHidden = true
                self.starLabel.text = ""
                self.defaultImage.isHidden = true
                self.toolBarSaveSpace.isEnabled = false
                self.toolBarSaveButton.isEnabled = false
                self.goodPupWatermark.isHidden = true
                self.loadBG.isHidden = true
                let navBarLogoImageView = UIImageView(image:self.navBarLogo)
                self.navigationItem.titleView = navBarLogoImageView
                self.navigationItem.title = "GoodPup"
                for breed in self.dogBreeds {
                    //print("array item: \(breed.lowercased())")
                    if firstResult.identifier.lowercased().contains(breed.lowercased()) {
                        self.resultLabel = self.positiveLabels[Int(arc4random_uniform(UInt32(self.positiveLabels.count)))]
                        self.starView.isHidden = false
                        self.starLabel.text = self.resultLabel
                        self.positiveChecker = true
                        self.toolBarSaveSpace.isEnabled = true
                        self.toolBarSaveButton.isEnabled = true
                        self.goodPupWatermark.isHidden = false
                        break
                    }
                }
                if self.positiveChecker == false {
                    navBar.barTintColor = UIColor(hexString: "#E56464")
                    let errorNavView = UIView()
                    let errorLabel = UILabel()
                    errorLabel.text = self.resultLabel
                    errorLabel.textColor = FlatWhite()
                    errorLabel.font = errorLabel.font.withSize(22)
                    errorLabel.sizeToFit()
                    errorLabel.center = errorNavView.center
                    errorNavView.addSubview(errorLabel)
                    self.navigationItem.titleView = errorNavView
                }
                
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

