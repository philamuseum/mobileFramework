//
//  Asset.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class LocationAsset: JSONDecodable {
    
    private(set) var locations = [Location]()
    
    public required init?(JSON: Any) {
        guard let JSON = JSON as? [[String: Any]] else { return nil }
        
        var locations = [Location]()
        
        for location in JSON {
            
            guard let name = location["Name"] as? String else { return nil }
            guard let title = location["Title"] as? String else { return nil }
            guard let floorName = location["Floor"] as? String else { return nil }
            guard let open = location["Open"] as? Bool else { return nil }
            
            guard let floor = Constants.floors.enumFromString(string: floorName) else { return nil }
            
            let location = Location(name: name, title: title, active: open, floor: floor)
            
            locations.append(location)
            
        }
        
        self.locations = locations
    }
}

extension LocationAsset: Equatable {
    public  static func == (lhs: LocationAsset, rhs: LocationAsset) -> Bool {
        return lhs.locations == rhs.locations
    }
}
