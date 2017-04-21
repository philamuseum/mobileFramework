//
//  BeaconStore.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class BeaconStore {
    
    static let sharedInstance = BeaconStore()
    
    private(set) var beacons = [Beacon]()
    private(set) var beaconsInRange = [Beacon]()
    
    func add(beacon: Beacon) {
        beacons.append(beacon)
    }
    
    func isKnown(major: Int, minor: Int, UUID: UUID) -> Bool {
        
       return findBeaconFor(major: major, minor: minor, UUID: UUID) != nil
        
    }
    
    func markInRange(major: Int, minor: Int, UUID: UUID) {
        if let beacon = findBeaconFor(major: major, minor: minor, UUID: UUID) {
            beaconsInRange.append(beacon)
        }
        
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
