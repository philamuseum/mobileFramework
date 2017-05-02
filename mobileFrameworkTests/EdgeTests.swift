//
//  EdgeTests.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class EdgeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_resolving_gallery_names() {
        
        let sampleLocationA = Location(name: "166", title: "166", active: true, floor: .first)
        let sampleLocationB = Location(name: "167", title: "167", active: true, floor: .first)
        
        let sampleEdge = Edge(nodeA: "166", nodeB: "167", weight: 1.0)
        
        XCTAssertEqual("166", sampleEdge.nodeAName)
        XCTAssertEqual("167", sampleEdge.nodeBName)
        
        XCTAssertNil(sampleEdge.nodeA)
        XCTAssertNil(sampleEdge.nodeB)
        
        sampleEdge.resolveNodeLocations(nodeA: sampleLocationA, nodeB: sampleLocationB)
        
        XCTAssertEqual(sampleLocationA, sampleEdge.nodeA)
        XCTAssertEqual(sampleLocationB, sampleEdge.nodeB)
        
    }
    
}
