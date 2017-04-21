//
//  galleryLocationService.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/19/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import UIKit
import CoreLocation

enum GalleryLocationManagerError: Error {
    case missingRegion
    case insufficientPermissions
}

class GalleryLocationManager : NSObject  {
    
    private var locationManager : CLLocationManager!
    var beaconRegion: CLBeaconRegion?
    
    init(locationManager: CLLocationManager) {
        super.init()
        self.locationManager = locationManager
        self.locationManager.delegate = self
    }
    
    var desiredAccuracy : CLLocationAccuracy {
        set(value) {
            locationManager.desiredAccuracy = value
        }
        get {
            return locationManager.desiredAccuracy
        }
    }
    
   
    func startLocationRanging() throws {
        if beaconRegion != nil {
            if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
                throw GalleryLocationManagerError.insufficientPermissions
            } else {
                // let's finally start
                locationManager.startRangingBeacons(in: beaconRegion!)
            }
        } else {
            throw GalleryLocationManagerError.missingRegion
        }
    }
    
    func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
    

    
    
    
}

extension GalleryLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
    }
    
    func locationManager(locationManager: GalleryLocationManager, didEnterLocation: String) {
        
    }
}
