//
//  Constants.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class Constants {
    
    public struct cache {
        static let dataModel = "mobileFramework"
        static let entity = "DownloadItem"
        public struct environment {
            public static let staging = "staging"
            public static let live = "live"
            public static let manual = "misc"
        }
    }
    
    public struct queue {
        static let updateFrequency : Double = 0.25
        static let maxConcurrentOperations = -1 // -1 is system default, will dynamically adjust
    }
    
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
        static func enumFromLevelID(string:String) -> floors? {
            let digit = Int(String(string.characters.last!))
            let floor = digit! - 1
            
            return floors(rawValue: floor)
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
