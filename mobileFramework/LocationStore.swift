//
//  LocationStore.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/27/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class LocationStore {
    
    static var sharedInstance = LocationStore()
    
    static func reset() {
        sharedInstance = LocationStore()
    }
    
    private(set) var locations = [Location]()
    private(set) var edges = [Edge]()
    
    func add(location: Location) {
        locations.append(location)
    }
    
    func findLocationByName(name: String) -> Location? {
        let result = locations.filter() {
            return $0.name == name
        }
        
        if result.count == 1 {
            return result.first!
        } else {
            return nil
        }
    }

    
    func locationForBeacon(beacon: Beacon) -> Location? {
        guard let alias = beacon.alias else { return nil }
        var cleanedAlias = alias
        
        let aliasMatches = matches(for: "[_][A-Z]{1}", in: alias)
        if aliasMatches.count > 0 {
            
            for replacement in Constants.beacons.validAliasReplacements {
                cleanedAlias = cleanedAlias.replacingOccurrences(of: replacement, with: "") as String
            }
        }
        
        let location = findLocationByName(name: cleanedAlias)
        return location
    }
    
    func load(fromAsset: LocationAsset) {
        self.locations = fromAsset.locations
    }
    
    func load(fromAsset: EdgeAsset) {
        self.edges = fromAsset.edges
        
        for edge in self.edges {
            guard let nodeA = findLocationByName(name: edge.nodeAName) else { return }
            guard let nodeB = findLocationByName(name: edge.nodeBName) else { return }
            
            edge.resolveNodeLocations(nodeA: nodeA, nodeB: nodeB)
        }
    }
    
    // http://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    private func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }


}
