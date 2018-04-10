//
//  GeoJSONAsset.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/12/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import MapKit

struct GeoJSON {
    let name : String
    let floor: Constants.floors?
    let unitId: String
    let polygon : MKPolygon
    let coordinates : [CLLocationCoordinate2D]
}

public class GeoJSONAsset: JSONDecodable {
    
    private(set) var locations = [GeoJSON]()
    
    private(set) var JSON : [String: Any]
    
    public required init?(JSON: Any) {
        guard let JSON = JSON as? [String: Any] else { return nil }
        
        guard let features = JSON["features"] as? [[String: Any]] else { print("GeoJSONAsset ERROR: JSON[\"features\"] missing"); return nil }

        var locations = [GeoJSON]()
        
        for feature in features {
            
            guard let properties = feature["properties"] as? [String: Any] else { print("GeoJSONAsset ERROR: feature[\"properties\"] missing"); return nil }
            
            var name = properties["SUITE"] as? String
            
            if name == nil {
                name = properties["UNIT_ID"] as? String
            }
            
            guard let unitID = properties["UNIT_ID"] as? String else { print("GeoJSONAsset ERROR: properties[\"UNIT_ID\"] missing"); return nil }
            
            guard let floorName = properties["LEVEL_ID"] as? String else { print("GeoJSONAsset ERROR: properties[\"LEVEL_ID\"] missing");return nil }
            
            guard let geometry = feature["geometry"] as? [String: Any] else { print("GeoJSONAsset ERROR: feature[\"geometry\"] missing"); return nil }
            
            let floor = Constants.floors.enumFromLevelID(string: floorName)
            
            var coordinates = [CLLocationCoordinate2D]()

            
            // apparently Rodin maps use MultiPolygons and Main Building maps use Polygons
            if geometry["type"] as? String == "Polygon" {
                guard let coordinatesStacked = geometry["coordinates"] as? [[[Double]]] else {
                    print("cannot parse coordinates")
                    return nil
                }
                
                for coord in coordinatesStacked.first! {
                    let lat = coord[1]
                    let lon = coord[0]
                    let locationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    coordinates.append(locationCoordinate)
                }
                
            } else if geometry["type"] as? String == "MultiPolygon" {
                guard let coordinatesStacked = geometry["coordinates"] as? [[[[Double]]]] else {
                    print("cannot parse coordinates")
                    return nil
                }
                
                for coord in coordinatesStacked.first!.first! {
                    let lat = coord[1]
                    let lon = coord[0]
                    let locationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    
                    coordinates.append(locationCoordinate)
                }
            }
            
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            
            if name != nil {
                
                let obj = GeoJSON(name: name!, floor: floor, unitId: unitID, polygon: polygon, coordinates: coordinates)
                print("GeoJSONAsset: Loaded suite: \(String(describing: name)), coordinate count: \(obj.coordinates.count), floor: \(String(describing: floor))")
                
                locations.append(obj)
            }
        }
        
        self.locations = locations
        self.JSON = JSON
    }
}

extension GeoJSONAsset: Equatable {
    public  static func == (lhs: GeoJSONAsset, rhs: GeoJSONAsset) -> Bool {
        return lhs.JSON.count == rhs.JSON.count
    }
}
