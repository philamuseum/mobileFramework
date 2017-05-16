//
//  CacheServiceTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/16/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class CacheServiceTests: XCTestCase {
    
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
    
    // getLocalPathForURL
    
    func test_get_local_path_for_remote_URL() {
        
        let service = CacheService()
        
        let url = URL(string: "http://localhost/api/v0/collection/objectIsOnView?query=4&api_token=WtPr21h94VqPLxEo8079vzg1ZcE6sIwYYcXur80EOULRB79zO0WBqdERk5hG")
        
        let expectedPath = service.cacheURL
            .appendingPathComponent(Bundle(for: type(of: self)).bundleIdentifier!)
            .appendingPathComponent(service.manualRequestRepository)
            .appendingPathComponent("api")
            .appendingPathComponent("v0")
            .appendingPathComponent("collection")
            .appendingPathComponent("objectIsOnView")
        
        let resultPath = service.getLocalPathForURL(url: url!, repository: service.manualRequestRepository)
        
        XCTAssertEqual(expectedPath, resultPath)
    }
    
    func test_load_single_file_uncached_from_network() {
        
        let expectationSuccess = expectation(description: "Waiting for caching service to process request.")
        
        let service = CacheService()
        
        let url = URL(string: "http://localhost/api/v0/collection/objectIsOnView?query=4&api_token=WtPr21h94VqPLxEo8079vzg1ZcE6sIwYYcXur80EOULRB79zO0WBqdERk5hG")
        
        let sampleJSON = "{\"onView\":false,\"ObjectID\":4,\"ObjectNumber\":\"1985-52-14899\"}"
        let urlData = sampleJSON.data(using: .utf8)
        
        service.request(url: url!, uncached: true) { localPath, data in
            
            XCTAssertNil(localPath)
            XCTAssertNotNil(data)
            
            XCTAssertEqual(urlData, data)
            
            expectationSuccess.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
        
    func test_load_single_file_cached_with_file_not_available_locally() {
        
        let expectationSuccess = expectation(description: "Waiting for caching service to process request.")
        
        let service = CacheService()
        
        let url = URL(string: "http://localhost/api/v0/collection/objectIsOnView?query=4&api_token=WtPr21h94VqPLxEo8079vzg1ZcE6sIwYYcXur80EOULRB79zO0WBqdERk5hG")
        
        let sampleJSON = "{\"onView\":false,\"ObjectID\":4,\"ObjectNumber\":\"1985-52-14899\"}"
        let urlData = sampleJSON.data(using: .utf8)
        
        let servicePath = service.getLocalPathForURL(url: url!, repository: service.manualRequestRepository)
        if FileManager.default.fileExists(atPath: servicePath.path) {
            try! FileManager.default.removeItem(atPath: servicePath.path)
        }
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: servicePath.path))
        
        service.request(url: url!, uncached: false) { localPath, data in
            
            XCTAssertNotNil(localPath)
            XCTAssertNotNil(data)
            
            XCTAssertEqual(urlData, data)
            
            let resultJSON = String(data: data!, encoding: .utf8)
            
            XCTAssertEqual(sampleJSON, resultJSON)
            XCTAssertTrue(FileManager.default.fileExists(atPath: localPath!.path))
            
            expectationSuccess.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
    }
    
    func test_load_single_file_cached_with_file_locally_available() {
        
        let expectationSuccess = expectation(description: "Waiting for caching service to process request.")
        
        let service = CacheService()
        
        let url = URL(string: "http://localhost/api/v0/collection/objectIsOnView?query=4&api_token=WtPr21h94VqPLxEo8079vzg1ZcE6sIwYYcXur80EOULRB79zO0WBqdERk5hG")
        
        let sampleJSON = "{\"onView\":true,\"ObjectID\":4,\"ObjectNumber\":\"1985-52-14899\"}"
        let urlData = sampleJSON.data(using: .utf8)
        
        let servicePath = service.getLocalPathForURL(url: url!, repository: service.manualRequestRepository)
        
        var localPathWithoutFilename = servicePath
        localPathWithoutFilename.deleteLastPathComponent()
        try! FileManager.default.createDirectory(atPath: localPathWithoutFilename.path, withIntermediateDirectories: true, attributes: nil)
        
        try! sampleJSON.write(toFile: servicePath.path, atomically: true, encoding: .utf8)
        
        service.request(url: url!, uncached: false) { localPath, data in
            
            XCTAssertNotNil(localPath)
            XCTAssertNotNil(data)
            
            XCTAssertEqual(urlData, data)
            
            let resultJSON = String(data: data!, encoding: .utf8)
            
            XCTAssertEqual(sampleJSON, resultJSON)
            XCTAssertTrue(FileManager.default.fileExists(atPath: localPath!.path))
            
            expectationSuccess.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
    }
    
}
