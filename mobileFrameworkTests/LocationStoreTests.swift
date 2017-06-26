//
//  LocationStoreTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/27/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest
import CoreLocation
import MapKit

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
    
    func test_add_location_with_polygon() {
        let store = LocationStore()
        
        var coordinates = [CLLocationCoordinate2D]()
        
        coordinates.append(CLLocationCoordinate2D(latitude: 39.96501561000008, longitude: -75.181273465999936))
        coordinates.append(CLLocationCoordinate2D(latitude: 39.965012548000061, longitude: -75.181277315999921))
        coordinates.append(CLLocationCoordinate2D(latitude: 39.965018103000034, longitude: -75.181284622999897))
        coordinates.append(CLLocationCoordinate2D(latitude: 39.965018599000075, longitude: -75.181285274999937))
        
        let samplePolygon = MKPolygon(coordinates: &coordinates, count: coordinates.count)
        
        let sampleLocation = Location(name: "166", title: "166", active: true, floor: .first, polygon: samplePolygon, coordinates: coordinates)
        
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
    
    func test_get_location_for_coordinate() {
        
        var sampleCoordinates = [CLLocationCoordinate2D]()
        
        sampleCoordinates.append(CLLocationCoordinate2D(latitude: 39.96511746533821, longitude: -75.18134329650225))
        sampleCoordinates.append(CLLocationCoordinate2D(latitude: 39.965097760926454, longitude: -75.18124935927544))
        sampleCoordinates.append(CLLocationCoordinate2D(latitude: 39.96501666967046, longitude: -75.18131659855469))
        sampleCoordinates.append(CLLocationCoordinate2D(latitude: 39.96507767758396, longitude: -75.18138383783392))
        
        let samplePolygon = MKPolygon(coordinates: &sampleCoordinates, count: sampleCoordinates.count)

        
        let sampleLocation = Location(name: "166", title: "166", active: true, floor: .first, polygon: samplePolygon, coordinates: sampleCoordinates)
        
        let sampleLocationWithinPolygon = CLLocation(latitude: 39.965080709037295, longitude: -75.18132352024095)
        
        let lStore = LocationStore()
        lStore.add(location: sampleLocation)
        
        guard let locationResult = lStore.locationForCLLocation(location: sampleLocationWithinPolygon, ignoreFloors: true) else {
            XCTFail("location not found for coordinate")
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
    
    func test_loading_units_geojson_from_file() {
        
        let store = LocationStore()
        
        let feature = FeatureStore()
        
        do {
            try feature.load(filename: "sampleLocations", type: .location, completion: {
                if let asset = feature.getAsset(for: .location) as? LocationAsset {
                    store.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown")
        }
        
        XCTAssertEqual(3, store.locations.count)
        
        do {
            try feature.load(filename: "sampleUnits", ext: "geojson", type: .geojson, completion: {
                if let asset = feature.assets[1] as? GeoJSONAsset {
                    store.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown: \(error)")
        }
        
        XCTAssertEqual(3, store.locations.count)
        XCTAssertEqual("175", store.locations.last?.name)
        XCTAssertEqual(53, store.locations.last?.coordinates?.count)
    }
    
    func test_matching_edge_names_to_locations() {
        
        let lStore = LocationStore()
        
        let fStore = FeatureStore()
        
        do {
            try fStore.load(filename: "sampleLocations", type: .location, completion: {
                if let asset = fStore.getAsset(for: .location) as? LocationAsset {
                    lStore.load(fromAsset: asset)
                }
            })
            
            try fStore.load(filename: "sampleEdges", type: .edge, completion: {
                if let asset = fStore.getAsset(for: .edge) as? EdgeAsset {
                    lStore.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown")
        }
        
        XCTAssertEqual(lStore.findLocationByName(name: "100"), lStore.edges.first?.nodeA)
        
    }
    
    func test_find_location_with_substitute_name() {
        
        let lStore = LocationStore()
        
        let fStore = FeatureStore()
        
        let testSubstitution = [
            "0229": "175",
        ]
        
        lStore.locationNameSubstitutions = testSubstitution
        
        do {
            try fStore.load(filename: "sampleLocations", type: .location, completion: {
                if let asset = fStore.getAsset(for: .location) as? LocationAsset {
                    lStore.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown: \(error)")
        }
        
        do {
            try fStore.load(filename: "sampleUnits", ext: "geojson", type: .geojson, completion: {
                if let asset = fStore.getAsset(for: .geojson) as? GeoJSONAsset {
                    lStore.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown: \(error)")
        }
        
        let locationWithOriginalName = lStore.findLocationByName(name: "175")
        let locationWithSubstitutedName = lStore.findLocationByName(name: "0229")
        
        XCTAssertNotNil(locationWithOriginalName)
        XCTAssertNotNil(locationWithSubstitutedName)
        
        XCTAssertEqual(locationWithOriginalName, locationWithSubstitutedName)

    }
    
    func test_get_location_for_CLLocation_with_floor_information() {
        let lStore = LocationStore()
        
        let fStore = FeatureStore()
        
        do {
            try fStore.load(filename: "sampleLocations", type: .location, completion: {
                if let asset = fStore.getAsset(for: .location) as? LocationAsset {
                    lStore.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown: \(error)")
        }
        
        do {
            try fStore.load(filename: "sampleUnits", ext: "geojson", type: .geojson, completion: {
                if let asset = fStore.getAsset(for: .geojson) as? GeoJSONAsset {
                    lStore.load(fromAsset: asset)
                }
            })
        } catch {
            XCTFail("Exception thrown: \(error)")
        }
        
        XCTAssertNotNil(lStore.findLocationByName(name: "175")?.coordinates)
        
        let sampleLocation = CLLocationMock(latitude: 39.96615993551854, longitude: -75.18052697181702)
        sampleLocation.testFloor = CLFloorMock()
        sampleLocation.testFloor?.testLevel = 1
        
        XCTAssertEqual(1, sampleLocation.floor?.level)
        
        XCTAssertEqual(1, Constants.floors.enumFromCLFloor(floor: sampleLocation.floor)?.rawValue)
        
        guard let locationResult = lStore.locationForCLLocation(location: sampleLocation) else {
            XCTFail("location not found for location")
            return
        }
        
        XCTAssertEqual("175", locationResult.name)
    }
    
}
