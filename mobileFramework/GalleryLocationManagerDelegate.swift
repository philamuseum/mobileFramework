//
//  GalleryLocationManagerDelegate.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import UIKit
import CoreLocation

protocol GalleryLocationManagerDelegate : CLLocationManagerDelegate {
    func locationManager(locationManager: GalleryLocationManager, didEnterLocation: String)
}

//class GalleryLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
//    
//
//}
