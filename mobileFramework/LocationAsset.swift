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
        
        let keysExcludedFromOptionalAttributes = ["Name", "Title", "Floor", "Open"]
        
        for location in JSON {
            
            var customAttributes : [String: Any] = [:]
            
            for key in location.keys {
                if !keysExcludedFromOptionalAttributes.contains(key) {
                    customAttributes[key] = location[key]
                }
            }
            
            guard let name = location["Name"] as? String else { return nil }
            
            var title : String!
            
            if let t = location["Title"] as? String {
                title = t
            } else {
                title = ""
            }
            
            guard let floorName = location["Floor"] as? String else { return nil }
            guard let open = location["Open"] as? Bool else { return nil }
            
            guard let floor = Constants.floors.enumFromString(string: floorName) else { return nil }
            
            //print("location \(name) successfully parsed")
            
            let location = Location(name: name, title: title, active: open, floor: floor)
            print("LocationAsset: Loaded location: \(String(describing: name)), title: \(title), floor: \(floor), open: \(open)")
            location.customAttributes = customAttributes
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
