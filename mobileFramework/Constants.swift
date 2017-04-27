//
//  Constants.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class Constants {
    
    enum floors {
        case ground
        case first
        case second
    }
    
    struct beacons {
        static let defaultTTL : Int = 3
        static let validAliasReplacements = ["_L", "_R", "_C", "_T", "_M", "_B"]
        
    }
    
}
