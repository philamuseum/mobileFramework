//
//  AssetStoreTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class FeatureStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_load_beacon_JSON_file() {
        
        let store = FeatureStore()
        
        XCTAssertEqual(0, store.assets.count)
        
        let expectationSuccess = expectation(description: "Loading JSON file")
        
        do {
            try store.load(filename: "sampleBeacons", ext: "json", type: .beacon, completion: {
                expectationSuccess.fulfill()
            })
        } catch FeatureStoreError.fileNotFound {
            XCTFail("Sample file not found")
        } catch FeatureStoreError.ParsingError {
            XCTFail("Error parsing sample file")
        } catch {
            XCTFail("Unknown error thrown")
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        XCTAssertEqual(1, store.assets.count)
        
    }
    
    func test_load_location_JSON_file() {
        
        let store = FeatureStore()
        
        XCTAssertEqual(0, store.assets.count)
        
        let expectationSuccess = expectation(description: "Loading JSON file")
        
        do {
            try store.load(filename: "sampleLocations", ext: "json", type: .location, completion: {
                expectationSuccess.fulfill()
            })
        } catch FeatureStoreError.fileNotFound {
            XCTFail("Sample file not found")
        } catch FeatureStoreError.ParsingError {
            XCTFail("Error parsing sample file")
        } catch {
            XCTFail("Unknown error thrown")
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        XCTAssertEqual(1, store.assets.count)
        
    }
    
    func test_load_edge_JSON_file() {
        
        let store = FeatureStore()
        
        XCTAssertEqual(0, store.assets.count)
        
        let expectationSuccess = expectation(description: "Loading JSON file")
        
        do {
            try store.load(filename: "sampleEdges", ext: "json", type: .edge, completion: {
                expectationSuccess.fulfill()
            })
        } catch FeatureStoreError.fileNotFound {
            XCTFail("Sample file not found")
        } catch FeatureStoreError.ParsingError {
            XCTFail("Error parsing sample file")
        } catch {
            XCTFail("Unknown error thrown")
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
        XCTAssertEqual(1, store.assets.count)
        
    }
    
    func test_get_asset_for_type() {
        let store = FeatureStoreMock()
        
        let beaconJSONData = "{ \"devices\": [{ \"alias\": \"LFH_R\", \"major\": 46453, \"minor\": 61315, \"uniqueId\": \"OlDU\" }] }".data(using: .utf8)
        let beaconJSON = try! JSONSerialization.jsonObject(with: beaconJSONData!, options: [])
        let beaconAsset = BeaconAsset(JSON: beaconJSON)
        store.addAsset(asset: beaconAsset!)
        
        let edgeJSONData = "[{ \"nodeA\": \"179\", \"nodeB\": \"183\", \"weight\":1}]".data(using: .utf8)
        let edgeJSON = try! JSONSerialization.jsonObject(with: edgeJSONData!, options: [])
        let edgeAsset = EdgeAsset(JSON: edgeJSON)
        store.addAsset(asset: edgeAsset!)
        
        let locationJSONData = "[{ \"Name\": \"100\", \"Title\": \"100\", \"Floor\": \"first\", \"Open\": true }]".data(using: .utf8)
        let locationJSON = try! JSONSerialization.jsonObject(with: locationJSONData!, options: [])
        let locationAsset = LocationAsset(JSON: locationJSON)
        store.addAsset(asset: locationAsset!)
        
        let geoJSONData = "{ \"type\": \"FeatureCollection\", \"features\": [ { \"type\": \"Feature\", \"properties\": { \"UNIT_ID\": \"0229\", \"CATEGORY\": \"Room\", \"LEVEL_ID\": \"0002\", \"NAME\": null, \"SUITE\": \"166\", \"RESTRICTED\": \"Unrestricted\", \"SOURCE\": \"CAD Drawing\", \"ADDRESS_ID\": null }, \"geometry\": { \"type\": \"Polygon\", \"coordinates\": [ [ [ -75.18049949899995, 39.966198637000048 ] ] ] } } ] }".data(using: .utf8)
        let geoJSON = try! JSONSerialization.jsonObject(with: geoJSONData!, options: [])
        let geoAsset = GeoJSONAsset(JSON: geoJSON)
        store.addAsset(asset: geoAsset!)
        
        XCTAssertEqual(beaconAsset!, store.getAsset(for: .beacon) as! BeaconAsset)
        XCTAssertEqual(edgeAsset!, store.getAsset(for: .edge) as! EdgeAsset)
        XCTAssertEqual(locationAsset!, store.getAsset(for: .location) as! LocationAsset)
        XCTAssertEqual(geoAsset!, store.getAsset(for: .geojson) as! GeoJSONAsset)
    }
    
}
