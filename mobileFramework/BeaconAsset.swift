//
//  Asset.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class BeaconAsset: JSONDecodable {
    
    private(set) var beacons = [Beacon]()
    
    public required init?(JSON: Any) {
        guard let JSON = JSON as? [String: AnyObject] else { return nil }
        
        guard let devices = JSON["devices"] as? [[String: Any]] else { return nil }
        
        print("devices: \(devices)")
        
        var beacons = [Beacon]()
        
        for device in devices {
            
            print("device")
        
            guard let alias = device["alias"] as? String else { return nil }
            guard let major = device["major"] as? Int else { return nil }
            guard let minor = device["minor"] as? Int else { return nil }
            guard let uniqueID = device["uniqueId"] as? String else { return nil }
            
            let beacon = Beacon(major: major, minor: minor, UUID: Constants.beacons.defaultUUID!, alias: alias, uniqueId: uniqueID)
            
            print("beacon: \(beacon)")
            
            beacons.append(beacon)
            
        }
        
        self.beacons = beacons
    }
}
