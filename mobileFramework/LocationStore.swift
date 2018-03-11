//
//  LocationStore.swift
//  mobileFramework
//
//  Created by Peter.Alt on 4/27/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import MapKit

public class LocationStore {
    
    public static var sharedInstance = LocationStore()
    
    static func reset() {
        sharedInstance = LocationStore()
    }
    
    public private(set) var locations = [Location]()
    public private(set) var edges = [Edge]()
    public var locationNameSubstitutions : [String : String] = [:]
    
    func add(location: Location) {
        locations.append(location)
    }
    
    public func findLocationByNameOrUnitId(name: String, unitId: String? = nil) -> Location? {
        var searchName = name
        
        // let's check first if we find the name
        if let index = self.locationNameSubstitutions.index(forKey: name) {
            searchName = self.locationNameSubstitutions[index].value
            print("LocationStore: Substituting location name '\(name)' with new name: '\(searchName)' (by name)")
            
        // if we can't find the location by name, try unitId instead
        } else if unitId != nil, let index = self.locationNameSubstitutions.index(forKey: unitId!) {
            searchName = self.locationNameSubstitutions[index].value
            print("LocationStore: Substituting location name '\(name)' with new name: '\(searchName)' (by unitId)")
        }
        
        let result = locations.filter() {
            return $0.name == searchName
        }
        
        if result.count == 1 {
            return result.first!
        } else {
            return nil
        }
    }
    
    public func locationForBeacon(beacon: Beacon) -> Location? {
        guard let alias = beacon.alias else { return nil }
        var cleanedAlias = alias
        
        let aliasMatches = matches(for: "[_][A-Z]{1}", in: alias)
        if aliasMatches.count > 0 {
            
            for replacement in Constants.beacons.validAliasReplacements {
                cleanedAlias = cleanedAlias.replacingOccurrences(of: replacement, with: "") as String
            }
        }
        
        let location = findLocationByNameOrUnitId(name: cleanedAlias)
        return location
    }
    
    public func locationForCLLocation(location: CLLocation, ignoreFloors : Bool = false) -> Location? {
        
        if let floor = Constants.floors.enumFromCLFloor(floor: location.floor) {
            // we have floor information
            //print("we found floor info: \(floor)")
            for storedLocation in self.locations {
                // we're on the same floor and we actually have coordinates
                if storedLocation.floor == floor && storedLocation.coordinates != nil {
                    if location.coordinate.contained(by: storedLocation.coordinates!) {
                        return storedLocation
                    }
                }
            }
        }
        else if ignoreFloors {
            // we don't have (valid) floor information and we want to ignore floors
            for storedLocation in self.locations {
                if storedLocation.coordinates != nil { // hack a static floor in here for testing purposes
                    if location.coordinate.contained(by: storedLocation.coordinates!) {
                        return storedLocation
                    }
                }
            }
        }
        return nil
    }
    
    public func load(fromAsset: LocationAsset) {
        self.locations = fromAsset.locations
    }
    
    public func load(fromAsset: EdgeAsset) {
        self.edges = fromAsset.edges
        
        for edge in self.edges {
            guard let nodeA = findLocationByNameOrUnitId(name: edge.nodeAName) else { return }
            guard let nodeB = findLocationByNameOrUnitId(name: edge.nodeBName) else { return }
            
            edge.resolveNodeLocations(nodeA: nodeA, nodeB: nodeB)
        }
    }
    
    public func load(fromAsset: GeoJSONAsset) {
        for geoJSONLocation in fromAsset.locations {
            //print("LocationStore: loading from asset: \(geoJSONLocation.name)")
            if let location = findLocationByNameOrUnitId(name: geoJSONLocation.name, unitId: geoJSONLocation.unitId) {
                //print("LocationStore: loading GeoJSON data into \(geoJSONLocation.name)")
                location.addGeoJSONData(polygon: geoJSONLocation.polygon, coordinates: geoJSONLocation.coordinates, unitId: geoJSONLocation.unitId)
            }
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

extension CLLocationCoordinate2D {
    
    func contained(by vertices: [CLLocationCoordinate2D]) -> Bool {
        let path = CGMutablePath()
        
        for vertex in vertices {
            if path.isEmpty {
                path.move(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            } else {
                path.addLine(to: CGPoint(x: vertex.longitude, y: vertex.latitude))
            }
        }
        
        let point = CGPoint(x: self.longitude, y: self.latitude)
        return path.contains(point)
    }
    
}
