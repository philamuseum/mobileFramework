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
//        let service = CacheService()
//        service.reset()
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
        
        let url = URL(string: "http://org.philamuseum.mobileframeworktests.s3.amazonaws.com/objectIsOnView_false.json")
        
        let expectedPath = service.cacheURL
            .appendingPathComponent(Bundle(for: type(of: self)).bundleIdentifier!)
            .appendingPathComponent(Constants.cache.environment.manual, isDirectory: true)
            .appendingPathComponent("objectIsOnView_false.json")
        
        let resultPath = service.getLocalPathForURL(url: url!, repository: Constants.cache.environment.manual)
        
        XCTAssertEqual(expectedPath, resultPath)
    }
    
    func test_load_single_file_uncached_from_network() {
        
        let expectationSuccess = expectation(description: "Waiting for caching service to process request.")
        
        let service = CacheService()
        
        let url = URL(string: "http://org.philamuseum.mobileframeworktests.s3.amazonaws.com/objectIsOnView_false.json")
        
        let referenceData = try! Data(contentsOf: url!)
        
        service.requestData(url: url!, forceUncached: true) { localPath, data in
            
            XCTAssertNil(localPath)
            XCTAssertNotNil(data)
            
            XCTAssertEqual(referenceData, data)
            
            expectationSuccess.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
        
    func test_load_single_file_cached_with_file_not_available_locally() {
        
        let expectationSuccess = expectation(description: "Waiting for caching service to process request.")
        
        let service = CacheService()
        
        let url = URL(string: "http://org.philamuseum.mobileframeworktests.s3.amazonaws.com/objectIsOnView_false.json")
        
        let sampleJSON = "{\"onView\":false,\"ObjectID\":4,\"ObjectNumber\":\"1985-52-14899\"}\n"
        let urlData = sampleJSON.data(using: .utf8)
        
        let servicePath = service.getLocalPathForURL(url: url!, repository: Constants.cache.environment.manual)
        if FileManager.default.fileExists(atPath: servicePath.path) {
            try! FileManager.default.removeItem(atPath: servicePath.path)
        }
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: servicePath.path))
        
        service.requestData(url: url!, forceUncached: false) { localPath, data in
            
            XCTAssertNotNil(localPath)
            XCTAssertNotNil(data)
            
            XCTAssertEqual(urlData, data)
            
            let resultJSON = String(data: data!, encoding: .utf8)
            
            XCTAssertEqual(sampleJSON, resultJSON)
            XCTAssertTrue(FileManager.default.fileExists(atPath: localPath!.path))
            
            expectationSuccess.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
    }
    
    func test_load_single_file_cached_with_file_locally_available() {
        
        let expectationSuccess = expectation(description: "Waiting for caching service to process request.")
        
        let service = CacheService()
        
        let url = URL(string: "http://org.philamuseum.mobileframeworktests.s3.amazonaws.com/objectIsOnView_false.json")
        
        let sampleJSON = "{\"onView\":true,\"ObjectID\":4,\"ObjectNumber\":\"1985-52-14899\"}"
        let urlData = sampleJSON.data(using: .utf8)
        
        let servicePath = service.getLocalPathForURL(url: url!, repository: Constants.cache.environment.manual)
        
        var localPathWithoutFilename = servicePath
        localPathWithoutFilename.deleteLastPathComponent()
        try! FileManager.default.createDirectory(atPath: localPathWithoutFilename.path, withIntermediateDirectories: true, attributes: nil)
        
        try! sampleJSON.write(toFile: servicePath.path, atomically: true, encoding: .utf8)
        
        service.requestData(url: url!, forceUncached: false) { localPath, data in
            
            XCTAssertNotNil(localPath)
            XCTAssertNotNil(data)
            
            XCTAssertEqual(urlData, data)
            
            let resultJSON = String(data: data!, encoding: .utf8)
            
            XCTAssertEqual(sampleJSON, resultJSON)
            XCTAssertTrue(FileManager.default.fileExists(atPath: localPath!.path))
            
            expectationSuccess.fulfill()
        }
        
        waitForExpectations(timeout: 5) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
        
    }
    
    func test_purge_environment() {
        let service = CacheService()
        
        let testFile = "TEST"
        let repository = "purgeTest"
        let testURL = URL(string: "http://www.example.com/folder/subfolder/purgeTestFile.txt")!
        let testPath = service.getLocalPathForURL(url: testURL, repository: repository)
        
        XCTAssertFalse(service.fileExists(url: testURL, repository: repository))
        
        do {
            service.prepareDirectories(for: testURL, in: repository)
            try testFile.write(to: testPath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            XCTFail("Writing test file errored: \(error)")
        }
        
        XCTAssertTrue(service.fileExists(url: testURL, repository: repository))
        
        service.purgeEnvironment(environment: repository)
        
        XCTAssertFalse(service.fileExists(url: testURL, repository: repository))
    }
    
    func test_move_files_from_staging_to_live_environment() {
        let service = CacheService()
        
        let testFile = "TEST"
        let repository = Constants.cache.environment.staging
        let testURL = URL(string: "http://www.example.com/folder/subfolder/stagingTestfile.txt")!
        let testPath = service.getLocalPathForURL(url: testURL, repository: repository)
        
        service.purgeEnvironment(environment: Constants.cache.environment.live)
        
        XCTAssertFalse(service.fileExists(url: testURL, repository: repository))
        
        do {
            service.prepareDirectories(for: testURL, in: repository)
            try testFile.write(to: testPath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            XCTFail("Writing test file errored: \(error)")
        }
        
        XCTAssertTrue(service.fileExists(url: testURL, repository: repository))
        XCTAssertFalse(service.fileExists(url: testURL, repository: Constants.cache.environment.live))
        
        service.publishStagingEnvironment(completion: { success in
            XCTAssertTrue(success)
            XCTAssertTrue(service.fileExists(url: testURL, repository: Constants.cache.environment.live))
        })
        
        // cleanup
        
        service.purgeEnvironment(environment: repository)
        
    }
    
}
