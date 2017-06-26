//
//  CLLocationMock.swift
//  mobileFramework
//
//  Created by Peter.Alt on 6/26/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreLocation

class CLLocationMock : CLLocation {
    
    var testFloor : CLFloorMock?
    
    override var floor: CLFloor? {
        get {
            return testFloor
        }
    }
    
    
}
