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
    private var locationUpdateTimer : Timer?
    
    var beaconRegion: CLBeaconRegion?
    
    var delegate : GalleryLocationManagerDelegate?
    
    init(locationManager: CLLocationManager) {
        super.init()
        self.locationManager = locationManager
        self.locationManager.delegate = self
    }
    
    private var previousLocation : Location?
    
    var currentLocation : Location? {
        get {
            if let closestBeacon = BeaconStore.sharedInstance.closestBeacon {
                return LocationStore.sharedInstance.locationForBeacon(beacon: closestBeacon)
            } else {
                return nil
            }
        }
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
                self.locationUpdateTimer?.invalidate()
                self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: Constants.locationSensing.locationUpdateInterval, target: self, selector: #selector(checkForLocationUpdates), userInfo: nil, repeats: true)
            }
        } else {
            throw GalleryLocationManagerError.missingRegion
        }
    }
    
    func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    internal func checkForLocationUpdates() {
        // if we don't have a current location, we can skip right out
        guard let currentLocation = self.currentLocation else { return }
        
        if self.previousLocation == currentLocation {
            // previous and current location are identical, which means we haven't moved
            // so we don't need to trigger a location update
        } else {
            // we have to trigger an update since it seems like we moved
            self.delegate?.locationManager(locationManager: self, didEnterLocation: currentLocation)
            
            // and we also have to set the previous location to the current location
            self.previousLocation = currentLocation
        }
    }
    
    internal func beaconRanged(major: Int, minor: Int, UUID: UUID) {
        let store = BeaconStore.sharedInstance
    
        store.markInRange(major: major, minor: minor, UUID: UUID)
        
    }
    

    
    
    
}

extension GalleryLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // do some filtering here to get the closest beacon
        let beacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        
        if let closestBeacon = beacons.first {
            // we really only look for beacons within our defined UUID
            if closestBeacon.proximityUUID == Constants.beacons.defaultUUID {
                beaconRanged(major: closestBeacon.major.intValue, minor: closestBeacon.minor.intValue, UUID: region.proximityUUID)
            }
        }
        
    }
}
