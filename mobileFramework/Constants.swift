//
//  Constants.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public class Constants {
    
    public struct device {
        public static var deviceName : String {
            get {
                return UIDevice.current.name
            }
        }
        
        public static var deviceUUID : String {
            get {
                return UIDevice.current.identifierForVendor!.uuidString
            }
        }
        
        public static var systemVersion : String {
            get {
                return UIDevice.current.systemVersion
            }
        }
        
        public static var appVersion : String {
            get {
                let appInfo = Bundle.main.infoDictionary! as Dictionary<String,AnyObject>
                let shortVersionString = appInfo["CFBundleShortVersionString"] as! String
                return shortVersionString
            }
        }
        
        public static var batteryLevel : Int {
            get {
                return Int(UIDevice.current.batteryLevel * 100) * -1
            }
        }
        
        public static var isCharging : Bool {
            get {
                return UIDevice.current.batteryState != UIDeviceBatteryState.unplugged
            }
        }
        
        public static var hasNetworkConnection : Bool {
            get {
                return Reachability.isConnectedToNetwork()
            }
        }
    }
    
    public struct backend {
        public static var apiKey : String?
        public static var host : String?
        public static var registerEndpoint : String?
        public static var healthCheckEndpoint : String?
        public static let healthCheckInterval: Double = 30 * 60 // 30 min
    }
    
    public struct cache {
        static let dataModel = "mobileFramework"
        static let entity = "DownloadItem"
        static let urlProtocolKey = "mobileFrameworkURLProtocolHandled"
        static let urlProtocolForceUncachedRequestKey = "mobileFrameworkURLProtocolForcedUncached"
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
        
        public static func enumFromString(string:String) -> floors? {
            
            if string == "G" { return floors.ground }
            if string == "1" { return floors.first }
            if string == "2" { return floors.second }
            
            var i = 0
            while let item = floors(rawValue: i) {
                if String(describing: item) == string { return item }
                i += 1
            }
            return nil
        }
        public static func enumFromLevelID(string:String) -> floors? {
            let digit = Int(String(string.last!))
            let floor = digit! - 1
            
            return floors(rawValue: floor)
        }
        public static func enumFromCLFloor(floor: CLFloor?) -> floors? {
            if floor == nil {
                return nil
            }
            return floors(rawValue: floor!.level)
        }
    }
    
    public struct assets {
        static let beacons = "beacons.json"
    }
    
    public struct locationSensing {
        static let locationUpdateInterval : Double = 0.5
        public struct method {
            public static let beacon = "beacon"
            public static let apple = "apple"
        }
    }
    
    public struct beacons {
        public static let defaultUUID = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        public static let defaultTTL : Int = 3
        public static let validAliasReplacements = ["_L", "_R", "_C", "_T", "_M", "_B"]
    }
    
}
