//
//  GoodPupActivityIndicatorView.swift
//  GoodPup
//
//  Created by Ace Goulet on 9/1/18.
//  Copyright © 2018 AceGoulet, LLC. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import UIKit

class GoodPupActivityIndicatorView: UIView {
    
    var indicator: NVActivityIndicatorView!
    
    
    init( color:UIColor? = UIColor.blue ) {
        super.init( frame: UIScreen.main.bounds )
        indicator = NVActivityIndicatorView( frame: CGRect( origin: CGPoint( x: ( UIScreen.main.bounds.width / 2 ) - 30, y :( UIScreen.main.bounds.height - (UIScreen.main.bounds.height / 4) ) ), size: CGSize( width: 60, height: 60 ) ), type: .ballRotateChase, color: color, padding: 60 )
        self.addSubview( indicator )
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func startAnimating() {
        
        self.indicator.startAnimating()
    }
    
    
    func stopAnimating() {
        self.indicator.stopAnimating()
        
    }
    
    
}
