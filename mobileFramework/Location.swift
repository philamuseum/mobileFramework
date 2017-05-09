//
//  Location.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/27/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class Location {
    
    public let name : String
    public let title : String
    
    public var active : Bool
    
    public let floor : Constants.floors!
    
    
    init(name: String, title: String, active: Bool, floor: Constants.floors) {
        self.name = name
        self.title = title
        self.active = active
        self.floor = floor
    }
    
}

extension Location: Equatable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.name == rhs.name &&
            lhs.title == rhs.title &&
            lhs.floor == rhs.floor
    }
}

extension Location: Hashable {
    public var hashValue: Int {
        return name.hashValue ^ title.hashValue ^ floor.hashValue
    }
}
