//
//  CLFloorMock.swift
//  mobileFramework
//
//  Created by Peter.Alt on 6/26/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreLocation

class CLFloorMock : CLFloor {
    
    var testLevel : Int!
    
    override var level: Int {
        get {
            return testLevel
        }
    }
    
    
}
