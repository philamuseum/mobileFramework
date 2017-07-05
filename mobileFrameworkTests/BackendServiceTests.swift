//
//  BackendServiceTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 7/5/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class BackendServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_ask_for_notification_permissions() {
        
        let service = BackendServiceSpy()
        service.requestPermissions()
        
        XCTAssertTrue(service.didAskForPermissions)
    }
    
    func test_throws_error_without_granted_notification_permissions() {
        
        let service = BackendService()
        
        do {
            try service.registerForRemoteNotifications()
        } catch BackendServiceError.insufficientPermissions {
            return
        } catch {
            XCTFail("Wrong error thrown")
        }
        
        XCTFail("No error thrown")
    }
    
    func test_registering_device_to_backend_fails_without_configuration() {
        let service = BackendService()
        
        do {
            try service.registerDevice()
        } catch BackendServiceError.backendConfigurationMissing {
            return
        } catch {
            XCTFail("Wrong error thrown")
        }
        
        XCTFail("No error thrown")
    }
    
}
