//
//  AssetStore.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public enum FeatureStoreError: Error {
    case fileNotFound
    case ParsingError
}

public enum FeatureStoreType : Int {
    case beacon
    case location
    case edge
    case geojson
}

public class FeatureStore {
    
    public static var sharedInstance = FeatureStore()
    
    public internal(set) var assets = [Any]()
    
    public func load(filename: String, ext: String = "json", type: FeatureStoreType, completion: () -> Void) throws {
        
        let bundle = Bundle(for: type(of: self))
        guard let fileURL = bundle.url(forResource: filename, withExtension: ext)
            else { throw FeatureStoreError.fileNotFound }
        
        do {
            let localData = try Data(contentsOf: fileURL)
            let JSON = try JSONSerialization.jsonObject(with: localData, options: [])
            
            var asset : Any?
            
            if type == .beacon {
                asset = BeaconAsset(JSON: JSON) as Any
            } else if type == .location {
                asset = LocationAsset(JSON: JSON) as Any
            } else if type == .edge {
                asset = EdgeAsset(JSON: JSON) as Any
            } else if type == .geojson {
                asset = GeoJSONAsset(JSON: JSON) as Any
            }
            
            if let asset = asset {
                self.assets.append(asset)
            }
            completion()
        } catch {
            throw FeatureStoreError.ParsingError
        }
        
    }
    
    public func getAsset(for type: FeatureStoreType) -> Any? {
        
        for asset in self.assets {
            if let a = asset as? BeaconAsset, type == .beacon {
                return a
            }
            if let a = asset as? LocationAsset, type == .location {
                return a
            }
            if let a = asset as? EdgeAsset, type == .edge {
                return a
            }
            if let a = asset as? GeoJSONAsset, type == .geojson {
                return a
            }
        }
        return nil
    }
    
}
