//
//  GalleryLocationManagerDelegateSpy.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreLocation

class GalleryLocationManagerDelegateSpy: NSObject, GalleryLocationManagerDelegate {
    
    @nonobjc func locationManager(locationManager: GalleryLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }

    
    var didEnterLocationCalled = false
    
    @nonobjc func locationManager(locationManager: GalleryLocationManager, didEnterKnownLocation: Location) {
        self.didEnterLocationCalled = true
    }
}
