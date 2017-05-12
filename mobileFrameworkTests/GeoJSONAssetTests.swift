//
//  GeoJSONAssetTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/12/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class GeoJSONAssetTests: XCTestCase {
    
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
    
    func test_init_with_location() {
        
        let locationJSON = "{ \"type\": \"FeatureCollection\", \"features\": [ { \"type\": \"Feature\", \"properties\": { \"UNIT_ID\": \"0229\", \"CATEGORY\": \"Room\", \"LEVEL_ID\": \"0002\", \"NAME\": null, \"SUITE\": \"166\", \"RESTRICTED\": \"Unrestricted\", \"SOURCE\": \"CAD Drawing\", \"ADDRESS_ID\": null }, \"geometry\": { \"type\": \"Polygon\", \"coordinates\": [ [ [ -75.18049949899995, 39.966198637000048 ] ] ] } } ] }"
        
        let data = locationJSON.data(using: .utf8)
        let JSON = try! JSONSerialization.jsonObject(with: data!, options: [])
        
        let asset = GeoJSONAsset(JSON: JSON)
        
        XCTAssertEqual(1, asset!.locations.count)
        XCTAssertEqual("166", asset!.locations.first?.name)
        XCTAssertEqual(Constants.floors.first, asset!.locations.first?.floor)
        XCTAssertEqual(1, asset!.locations.first?.coordinates.count)
    }
    
}
