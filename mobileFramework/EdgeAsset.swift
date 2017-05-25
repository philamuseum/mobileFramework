//
//  EdgeAsset.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class EdgeAsset: JSONDecodable {
    
    private(set) var edges = [Edge]()
    
    public required init?(JSON: Any) {
        guard let JSON = JSON as? [[String: Any]] else { return nil }
        
        var edges = [Edge]()
        
        for edge in JSON {
            
            guard let nodeA = edge["nodeA"] as? String else { return nil }
            guard let nodeB = edge["nodeB"] as? String else { return nil }
            guard let weight = edge["weight"] as? Float else { return nil }
            
            let edge = Edge(nodeA: nodeA, nodeB: nodeB, weight: weight)
            
            edges.append(edge)
            
        }
        
        self.edges = edges
    }
}

extension EdgeAsset: Equatable {
    public  static func == (lhs: EdgeAsset, rhs: EdgeAsset) -> Bool {
        return lhs.edges == rhs.edges
    }
}
