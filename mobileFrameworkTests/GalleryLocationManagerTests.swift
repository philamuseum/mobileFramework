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
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
    
    
    
}
