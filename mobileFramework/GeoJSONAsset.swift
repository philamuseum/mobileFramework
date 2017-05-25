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
    let floor: Constants.floors
    let polygon : MKPolygon
    let coordinates : [CLLocationCoordinate2D]
}

public class GeoJSONAsset: JSONDecodable {
    
    private(set) var locations = [GeoJSON]()
    
    private(set) var JSON : [String: Any]
    
    public required init?(JSON: Any) {
        guard let JSON = JSON as? [String: Any] else { return nil }
        
        guard let features = JSON["features"] as? [[String: Any]] else { return nil }

        var locations = [GeoJSON]()
        
        for feature in features {
            
            guard let properties = feature["properties"] as? [String: Any] else { return nil }
            
            guard let name = properties["SUITE"] as? String else { return nil }
            guard let floorName = properties["LEVEL_ID"] as? String else { return nil }
            
            guard let geometry = feature["geometry"] as? [String: Any] else { return nil }
            
            guard let coordinatesStacked = geometry["coordinates"] as? [[[Double]]] else { return nil }
            
            guard let floor = Constants.floors.enumFromLevelID(string: floorName) else { return nil }
            
            
            var coordinates = [CLLocationCoordinate2D]()
            
            for coord in coordinatesStacked.first! {
                let lat = coord[0]
                let lon = coord[1]
                let locationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                coordinates.append(locationCoordinate)
            }
            
            let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
            
            
            let obj = GeoJSON(name: name, floor: floor, polygon: polygon, coordinates: coordinates)
            print("COUNT: \(obj.coordinates.count)")
            
            locations.append(obj)
            
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
