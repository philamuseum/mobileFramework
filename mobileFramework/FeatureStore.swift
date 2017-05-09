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
}

public class FeatureStore {
    
    public static var sharedInstance = FeatureStore()
    
    public private(set) var assets = [Any]()
    
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
            }
            
            if let asset = asset {
                self.assets.append(asset)
            }
            completion()
        } catch {
            throw FeatureStoreError.ParsingError
        }
        
    }
    
}