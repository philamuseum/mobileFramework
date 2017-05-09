//
//  Constants.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class Constants {
    
    public enum floors : Int {
        case ground
        case first
        case second
        
        static func enumFromString(string:String) -> floors? {
            var i = 0
            while let item = floors(rawValue: i) {
                if String(describing: item) == string { return item }
                i += 1
            }
            return nil
        }
    }
    
    public struct assets {
        static let beacons = "beacons.json"
    }
    
    public struct locationSensing {
        static let locationUpdateInterval : Double = 0.5
    }
    
    public struct beacons {
        public static let defaultUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        public static let defaultTTL : Int = 3
        public static let validAliasReplacements = ["_L", "_R", "_C", "_T", "_M", "_B"]
    }
    
}
