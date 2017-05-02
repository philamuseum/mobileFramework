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
    
    func test_load_JSON_file() {
        
        let store = FeatureStore()
        
        XCTAssertEqual(0, store.assets.count)
        
        let expectationSuccess = expectation(description: "Loading JSON file")
        
        do {
            try store.load(filename: "sampleBeacons", ext: "json", completion: {
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
    
}
