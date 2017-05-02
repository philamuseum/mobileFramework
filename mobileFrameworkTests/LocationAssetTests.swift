//
//  LocationAsset.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class LocationAssetTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_with_location() {
        
        let locationJSON = "[{ \"Name\": \"100\", \"Title\": \"100\", \"Floor\": \"first\", \"Open\": true }]"
        
        let data = locationJSON.data(using: .utf8)
        let JSON = try! JSONSerialization.jsonObject(with: data!, options: [])
        
        let asset = LocationAsset(JSON: JSON)
        
        XCTAssertEqual(1, asset!.locations.count)
    }
    
}
