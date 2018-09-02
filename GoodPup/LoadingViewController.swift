//
//  LoadingViewController.swift
//  GoodPup
//
//  Created by Ace Goulet on 9/1/18.
//  Copyright © 2018 AceGoulet, LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoadingViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var apiVersionNumber : Double = 0.0
    var dogBreedArray = ["Affenpinscher","Afghan Hound","Airedale","Akita Inu","Malamute","Coonhound","American Eskimo Dog"," Foxhound","American Pit Bull Terrier","American Staffordshire Terrier","American Water Spaniel","Anatolian Shepherd Dog","Australian Cattle","Australian Shepherd","Australian Terrier","Azawakh","Basenji","Basset Hound","Beagle","Bearded Collie","Beauceron","Bedlington Terrier","Belgian Laekenois","Belgian Malinois","Belgian Sheepdog","Belgian Tervuren","Bergamasco","Bernese Mountain Dog","Bichon Frisé","Biewer Terrier","Black &amp; Tan Coonhound","Black Russian Terrier","Bloodhound","Bluetick Coonhound","Boerboel","Border Collie","Border Terrier","Borzoi","Boston Terrier","Bouvier des Flandres","Boxer","Briard","Brittany","Brussels Griffon","Bull Terrier","Bulldog - American","Bullmastiff","Cairn Terrier","Canaan Dog","Cane Corso","Cardigan Welsh Corgi","Cavalier King Charles","Cesky Terrier","Chesapeake Bay Retriever","Chihuahua","Chinese Crested","Chinese Shar-Pei","Chinook","Chow Chow","Cirneco dell'Etna","Clumber Spaniel","Cocker Spaniel","Cocker Spaniel - English","Collie","Curly-Coated Retriever","Dachshund","Dalmatian","Dandie Dinmont Terrier","Doberman Pinscher","Dogo Argentino","English Bulldog","English Foxhound","English Pointer","English Setter","English Toy Spaniel","Entlebucher Mountain Dog","Field Spaniel","Fila Brasileiro","Finnish Lapphund","Finnish Spitz","Flat Coated Retriever","French Bulldog","German Pinscher","German Shepherd","German Shorthaired Pointer","German Wirehaired Pointer","Giant Schnauzer","Glen of Imaal Terrier","Golden Retriever","Goldendoodle","Gordon Setter","Great Dane","Great Pyrenees","Greater Swiss Mountain Dog","Greyhound","Harrier","Havana Silk Dog","Havanese","Ibizan Hound","Icelandic Sheepdog","Irish Setter","Irish Terrier","Irish Water Spaniel","Irish Wolfhound","Italian Greyhound","Jack Russell Terrier","Japanese Chin","Keeshond","Kerry Blue Terrier","Komondor","Kuvasz","Labradoodle","Labrador Retriever","Lakeland Terrier","Lhasa Apso","Lowchen","Maltese","Manchester Terrier","Mastiff","Miniature Bull Terrier","Miniature Pinscher","Miniature Schnauzer","NAID Breed","Neapolitan Mastiff","Newfoundland","Norfolk Terrier","Norwegian Buhund","Norwegian Elkhound","Norwegian Lundehund","Norwich Terrier","Nova Scotia Duck Tolling","Old English Sheepdog","Otterhound","Papillon","Parson Russell Terrier","Pekingese","Pembroke Welsh Corgi","Peruvian Inca Orchid","Petit Basset Griffon Vendéen","Pharaoh Hound","Plott Hound","Lowland","Pomeranian","Poodle - Standard","Poodle - Toy","Portuguese Podengo Pequeno","Portuguese Water Dog","Pug","Puli","Pumi","Pyrenean Shepherd","Rat Terrier","Redbone Coonhound","Rhodesian Ridgeback","Rottweiler","Saint Bernard","Saluki","Samoyed","Schipperke","Scottish Deerhound","Scottish Terrier","Sealyham Terrier","Shetland Sheepdog","Shiba Inu","Shih Tzu","Siberian Husky","Silky Terrier","Skye Terrier","Sloughi","Smooth Fox Terrier","Soft Coated Wheaten Terrier","Spinone Italiano","Springer Spaniel - English","Staffordshire Bull Terrier","Standard Schnauzer","Sussex Spaniel","Swedish Vallhund","Tibetan Mastiff","Tibetan Spaniel","Tibetan Terrier","Toy Fox Terrier","Treeing Walker Coonhound","Vizsla","Weimaraner","Welsh Springer Spaniel","Welsh Terrier","West Highland White Terrier","Whippet","Wire Fox Terrier","Wirehaired Pointing Griffon","Wirehaired Vizsla","Xoloitzcuintli","Yorkshire Terrier", "dog", "puppy", "pup", "poodle", "doodle", "wolf", "canine", "hound", "malamute", "terrier", "Schnauzer", "kelpie", "bulldog", "bluetick", "spaniel", "springer", "malinois"
    ]
    var positiveResponseArray = ["10/10 Good Dog!", "Who's a good pup? You Are!", "Good Dog!", "Good Pup deserves a treat!", "Belly rubs for the Good Dog!", "Give this good pup all the pets!", "Sweet Baby Angel!", "Extra food for this Good Dog!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(isKeyPresentInUserDefaults(key: "ApiVersion")){
            apiVersionNumber = defaults.double(forKey: "ApiVersion")
        }
        else {
            self.defaults.setValue(0.0, forKey: "ApiVersion")
        }
        
        if(isKeyPresentInUserDefaults(key: "DogBreeds")){
            if let dogBreeds = defaults.array(forKey: "DogBreeds") as? [String] {
                dogBreedArray = dogBreeds
            }
        }
        else {
            self.defaults.setValue(dogBreedArray, forKey: "DogBreeds")
        }
        
        if(isKeyPresentInUserDefaults(key: "PositiveResponses")){
            if let positiveResponses = defaults.array(forKey: "PositiveResponses") as? [String] {
                positiveResponseArray = positiveResponses
            }
        }
        else {
            self.defaults.setValue(positiveResponseArray, forKey: "PositiveResponses")
        }
        
        
        getGoodPupData(url: "https://www.acegoulet.com/goodpup/api.json")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //goToMainView()
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getGoodPupData(url: String){
        
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                
                let goodPupJson : JSON = JSON(response.result.value!)
                
                self.updateGoodPupData(json: goodPupJson)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                print("Problem getting api data")
                self.goToMainView()
            }
        }
        
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateGoodPupData(json : JSON){
        
        if let remoteApiVersion = json["version"].double {
            
            if remoteApiVersion > apiVersionNumber {
                self.defaults.setValue(remoteApiVersion, forKey: "ApiVersion")
                
                self.defaults.setValue(json["dogBreeds"].arrayObject, forKey: "DogBreeds")
                
                self.defaults.setValue(json["responses"]["positiveLabels"].arrayObject, forKey: "PositiveResponses")
                
                goToMainView()
            }
            else {
                print("no new remote data")
                goToMainView()
            }
        }
        else {
            print("couldn't find api data version in json")
            goToMainView()
        }
        
    }
    
    
    
    //check if user default key exists
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    //
    func goToMainView() {
        self.performSegue(withIdentifier: "loadScreenSegue", sender: self)
    }
}
