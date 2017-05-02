//
//  galleryLocationServiceTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/19/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest
import CoreLocation

class galleryLocationServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        BeaconStore.reset()
        LocationStore.reset()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_throw_exception_for_missing_location_permissions() {
        
        let locationManager = GalleryLocationManager(locationManager: CLLocationManagerSpy())
        
        let sampleUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let sampleRegion = CLBeaconRegion(proximityUUID: sampleUUID!, identifier: "identifier")
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.beaconRegion = sampleRegion
        
        do {
            try locationManager.startLocationRanging()
        } catch GalleryLocationManagerError.insufficientPermissions {
            return
        } catch {
            XCTFail("Wrong error thrown")
        }
      
        XCTFail("No error thrown")        
    }
    
    func test_throw_exception_for_missing_region() {
        
        let locationManager = GalleryLocationManager(locationManager: CLLocationManagerSpy())
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        do {
            try locationManager.startLocationRanging()
        } catch GalleryLocationManagerError.missingRegion {
            return
        } catch {
            XCTFail("Wrong error thrown")
        }
        
        XCTFail("No error thrown")
    }
    
    func test_ask_for_location_permissions() {
        
        let locationManager = GalleryLocationManagerSpy(locationManager: CLLocationManagerSpy())
        
        let sampleUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let sampleRegion = CLBeaconRegion(proximityUUID: sampleUUID!, identifier: "identifier")
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.beaconRegion = sampleRegion
        
        locationManager.requestPermissions()
        
        XCTAssertTrue(locationManager.didAskForPermissions)
        
       
    }
    
    func test_get_current_location_when_ranging_a_beacon() {
        
        let locationManager = GalleryLocationManager(locationManager: CLLocationManager())
        
        let sampleUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let sampleBeacon = Beacon(major: 1111, minor: 2222, UUID: sampleUUID!, alias: "166")
        BeaconStore.sharedInstance.add(beacon: sampleBeacon)
        BeaconStore.sharedInstance.markInRange(major: sampleBeacon.major, minor: sampleBeacon.minor, UUID: sampleUUID!)
        
        let sampleLocation = Location(name: "166", title: "166", active: true, floor: .first)
        LocationStore.sharedInstance.add(location: sampleLocation)

        locationManager.beaconRanged(major: sampleBeacon.major, minor: sampleBeacon.minor, UUID: sampleUUID!)
        
        XCTAssertEqual(sampleBeacon, BeaconStore.sharedInstance.closestBeacon)
        
        XCTAssertEqual(1, LocationStore.sharedInstance.locations.count)
        
        XCTAssertEqual(sampleLocation, LocationStore.sharedInstance.locationForBeacon(beacon: sampleBeacon))
        
        XCTAssertEqual(sampleLocation, locationManager.currentLocation)
        
        
    }
    
    func test_location_ranged_delegate_method_called() {
        
        let locationManager = GalleryLocationManager(locationManager: CLLocationManager())
        let delegate = GalleryLocationManagerDelegateSpy()
        locationManager.delegate = delegate
        
        let sampleUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let sampleBeacon = Beacon(major: 1111, minor: 2222, UUID: sampleUUID!, alias: "166")
        BeaconStore.sharedInstance.add(beacon: sampleBeacon)
        BeaconStore.sharedInstance.markInRange(major: sampleBeacon.major, minor: sampleBeacon.minor, UUID: sampleUUID!)
        
        let sampleLocation = Location(name: "166", title: "166", active: true, floor: .first)
        LocationStore.sharedInstance.add(location: sampleLocation)
        
        locationManager.beaconRanged(major: sampleBeacon.major, minor: sampleBeacon.minor, UUID: sampleUUID!)
        
        XCTAssertEqual(sampleLocation, locationManager.currentLocation)
        
        locationManager.checkForLocationUpdates()
        
        XCTAssertTrue(delegate.didEnterLocationCalled)
        
    }
    
    
}
