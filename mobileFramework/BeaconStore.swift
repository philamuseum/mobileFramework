//
//  BeaconStore.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class BeaconStore {
    
    public static var sharedInstance = BeaconStore()
    
    static func reset() {
        sharedInstance = BeaconStore()
    }
    
    public private(set) var beacons = [Beacon]()
    private(set) var beaconsInRange = [Beacon]()
    
    public var closestBeacon : Beacon? {
        get {
            
            var occurances : [Beacon:Int] = [:]
            
            let onlyBeaconsCurrentlyPresent = beaconsInRange.filter() {
                return $0.isPresent == true
            }
            
            _ = onlyBeaconsCurrentlyPresent.map{
                if let val: Int = occurances[$0]  {
                    occurances[$0] = val+1
                } else {
                    occurances[$0] = 1
                }
            }
            
            let sortedOccurances = occurances.sorted{ $0.value > $1.value }
            
            if sortedOccurances.count >= 2 && sortedOccurances[0].value == sortedOccurances[1].value {
                return nil
            }
            
            return sortedOccurances.first?.key
            
        }
    }
    
    func add(beacon: Beacon) {
        beacons.append(beacon)
    }
    
    func isKnown(major: Int, minor: Int, UUID: UUID) -> Bool {
        
       return findBeaconFor(major: major, minor: minor, UUID: UUID) != nil
        
    }
    
    public func markInRange(major: Int, minor: Int, UUID: UUID) {
        if let beacon = findBeaconFor(major: major, minor: minor, UUID: UUID) {
            beacon.setPresent()
            beaconsInRange.append(beacon)
        }
        
    }
    
    public func load(fromAsset: BeaconAsset) {
        self.beacons = fromAsset.beacons
    }
    
    private func findBeaconFor(major: Int, minor: Int, UUID: UUID) -> Beacon? {
        let result = beacons.filter() {
            let major = $0.major == major
            let minor = $0.minor == minor
            let UUID = $0.UUID.uuidString.compare(UUID.uuidString) == ComparisonResult.orderedSame
            return major && minor && UUID
        }
        
        if result.count == 1 {
            return result.first!
        } else {
            return nil
        }
    }
    
}
