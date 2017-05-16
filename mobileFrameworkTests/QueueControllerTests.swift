//
//  QueueControllerTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/16/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest
import CoreData

class QueueControllerTests: XCTestCase {
    
    var controller : QueueController!
    
    override func setUp() {
        super.setUp()
        
        controller = QueueController()
        controller.reset()
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
    
    func test_reset_store() {
        controller.reset()
        
        let context = controller.persistentContainer.viewContext
        
        let url = URL(string: "http://www.example.com")
        
        XCTAssertEqual(0, controller.getItems()?.count)
        
        if let entity = NSEntityDescription.entity(forEntityName: Constants.cache.entity, in: context) {
            let queueItem = NSManagedObject(entity: entity, insertInto: context)
            queueItem.setValue(url?.absoluteString, forKey: "url")
            queueItem.setValue(NSDate(), forKey: "created_at")
            
            controller.save(object: queueItem)
        }
        
        XCTAssertEqual(1, controller.getItems()?.count)
        
        controller.reset()
        
        XCTAssertEqual(0, controller.getItems()?.count)
        
    }
    
    func test_save_object_to_store() {
        controller.reset()
        
        let context = controller.persistentContainer.viewContext
        
        let url = URL(string: "http://www.example.com")
        
        XCTAssertEqual(0, controller.getItems()?.count)
        
        if let entity = NSEntityDescription.entity(forEntityName: Constants.cache.entity, in: context) {
            let queueItem = NSManagedObject(entity: entity, insertInto: context)
            queueItem.setValue(url?.absoluteString, forKey: "url")
            queueItem.setValue(NSDate(), forKey: "created_at")
            
            controller.save(object: queueItem)
        }
        
        XCTAssertEqual(1, controller.getItems()?.count)
        let item = controller.getItems()?.first
        XCTAssertEqual(url?.absoluteString, item?.value(forKey: "url") as? String)
    }
}
