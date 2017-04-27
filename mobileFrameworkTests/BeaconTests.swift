//
//  BeaconTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/27/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class BeaconTests: XCTestCase {
    
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
    
    func test_set_ttl() {
        let sampleUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        
        let beacon = Beacon(major: 1111, minor: 2222, UUID: sampleUUID!)
        
        beacon.setPresent()
        
        XCTAssertEqual(3, beacon.ttl)
        
        XCTAssertTrue(beacon.isPresent)
        
        
    }
    
    func test_ttl_expires() {
        
        let sampleUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        
        let beacon = Beacon(major: 1111, minor: 2222, UUID: sampleUUID!)
        
        beacon.setPresent()
        
        beacon.validateTTL()
        beacon.validateTTL()
        
        XCTAssertEqual(1, beacon.ttl)
        XCTAssertTrue(beacon.isPresent)
        
        beacon.validateTTL()
        
        XCTAssertEqual(nil, beacon.ttl)
        XCTAssertFalse(beacon.isPresent)

        
    }

    
}
