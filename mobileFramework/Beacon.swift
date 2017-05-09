//
//  Beacon.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/20/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class Beacon {
    
    let major : Int
    let minor: Int
    let UUID: UUID
    var alias : String?
    
    private(set) var ttl : Int?
    
    private var ttlTimer : Timer?
    
    var isPresent : Bool {
        get {
            return (self.ttl != nil)
        }
    }
    
    init(major: Int, minor: Int, UUID: UUID, alias: String?, uniqueId: String? = nil) {
        self.major = major
        self.minor = minor
        self.UUID = UUID
        self.alias = alias
    }
    
    func setPresent() {
        self.ttl = Constants.beacons.defaultTTL
        ttlTimer?.invalidate()
        ttlTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(validateTTL), userInfo: nil, repeats: true)
    }
    
    @objc internal func validateTTL() {
        
        if self.ttl != nil {
            if self.ttl! >= 1 {
                self.ttl! -= 1
            }
            if self.ttl! <= 0 {
                ttlTimer?.invalidate()
                self.ttl = nil
            }
        }
    }
    
    internal func setExpired() {
        self.ttl = nil
    }
    
}

extension Beacon: Equatable {
   public  static func == (lhs: Beacon, rhs: Beacon) -> Bool {
        return lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.UUID == rhs.UUID
    }
}

extension Beacon: Hashable {
    public var hashValue: Int {
        return major.hashValue ^ minor.hashValue ^ UUID.hashValue
    }
}


