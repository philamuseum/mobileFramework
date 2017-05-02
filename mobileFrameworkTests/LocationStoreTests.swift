//
//  LocationStoreTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/27/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class LocationStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_add_location() {
        let store = LocationStore()
        
        let sampleLocation = Location(name: "166", title: "166", active: true, floor: .first)
        
        XCTAssertEqual(0, store.locations.count)
        
        store.add(location: sampleLocation)
        
        XCTAssertEqual(1, store.locations.count)
    }
    
    func test_get_location_for_alias() {
        
        let sampleLocation = Location(name: "166", title: "166", active: true, floor: .first)
        
        LocationStore.sharedInstance.add(location: sampleLocation)

        guard let locationResult = LocationStore.sharedInstance.findLocationByName(name: "166") else {
            XCTFail("location not found for alias")
            return
        }
        
        XCTAssertEqual(sampleLocation, locationResult)
    }
    
    
    func test_get_location_for_beacon() {
        
        let sampleLocation = Location(name: "166", title: "166", active: true, floor: .first)
        
        let sampleUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        let sampleBeacon = Beacon(major: 1111, minor: 2222, UUID: sampleUUID!, alias: "166_T_L")
        
        guard let locationResult = LocationStore.sharedInstance.locationForBeacon(beacon: sampleBeacon) else {
            XCTFail("location not found for beacon")
            return
        }
        
        XCTAssertEqual(sampleLocation, locationResult)
        
    }
    
    func test_loading_locations_from_file() {
        
        let store = LocationStore()
        
        let feature = FeatureStore()
        
        do {
            try feature.load(filename: "sampleLocations", type: .location, completion: {
                if let asset = feature.assets.first as? LocationAsset {
                    store.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown")
        }
        
        XCTAssertEqual(3, store.locations.count)
    }
    
    func test_loading_edges_from_file() {
        
        let store = LocationStore()
        
        let feature = FeatureStore()
        
        do {
            try feature.load(filename: "sampleEdges", type: .edge, completion: {
                if let asset = feature.assets.first as? EdgeAsset {
                    store.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown")
        }
        
        XCTAssertEqual(2, store.edges.count)
    }
    
    func test_matching_edge_names_to_locations() {
        
        let lStore = LocationStore()
        
        let fStore = FeatureStore()
        
        do {
            try fStore.load(filename: "sampleLocations", type: .location, completion: {
                if let asset = fStore.assets[0] as? LocationAsset {
                    lStore.load(fromAsset: asset)
                }
            })
            
            try fStore.load(filename: "sampleEdges", type: .edge, completion: {
                if let asset = fStore.assets[1] as? EdgeAsset {
                    lStore.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown")
        }
        
        XCTAssertEqual(lStore.findLocationByName(name: "100"), lStore.edges.first?.nodeA)
        
    }
    
}
