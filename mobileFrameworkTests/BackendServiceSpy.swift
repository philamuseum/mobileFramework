//
//  BackendServiceSpy.swift
//  mobileFramework
//
//  Created by Peter.Alt on 7/5/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class BackendServiceSpy : BackendService {
    
    var didAskForPermissions = false
    
    public override func requestPermissions() {
        didAskForPermissions = true
    }
}
