//
//  Beacon.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class Beacon {
    
    let major : Int
    let minor: Int
    let UUID: UUID
    var alias : String?
    
    init(major: Int, minor: Int, UUID: UUID) {
        self.major = major
        self.minor = minor
        self.UUID = UUID
    }
    
}
