//
//  GalleryLocationManagerSpy.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import UIKit

class GalleryLocationManagerSpy: GalleryLocationManager {
    
    var didAskForPermissions = false
    
    override func requestPermissions() {
        didAskForPermissions = true
    }
    
    override func startLocationRanging(with method: String) throws {
        
    }
    

}
