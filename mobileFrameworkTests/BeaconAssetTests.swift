//
//  AssetTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class BeaconAssetTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_with_beacon() {
        
        let beaconJSON = "{ \"devices\": [{ \"alias\": \"LFH_R\", \"major\": 46453, \"minor\": 61315, \"uniqueId\": \"OlDU\" }] }"
        
        let data = beaconJSON.data(using: .utf8)
        let JSON = try! JSONSerialization.jsonObject(with: data!, options: [])
        
        let asset = BeaconAsset(JSON: JSON)
        
        XCTAssertEqual(1, asset!.beacons.count)
    }
    
    
}
