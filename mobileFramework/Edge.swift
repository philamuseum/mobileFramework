//
//  Edge.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class Edge {
    
    public let nodeAName : String
    public let nodeBName : String
    
    private(set) var nodeA : Location?
    private(set) var nodeB : Location?
    
    public let weight : Float
    
    init(nodeA: String, nodeB: String, weight: Float) {
        self.nodeAName = nodeA
        self.nodeBName = nodeB
        self.weight = weight
    }
    
    func resolveNodeLocations(nodeA: Location, nodeB: Location) {
        self.nodeA = nodeA
        self.nodeB = nodeB
    }
    
}

extension Edge: Equatable {
    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs.nodeA == rhs.nodeA &&
            lhs.nodeB == rhs.nodeB &&
            lhs.weight == rhs.weight
    }
}

extension Edge: Hashable {
    public var hashValue: Int {
        return nodeAName.hashValue ^ nodeBName.hashValue ^ weight.hashValue
    }
}
