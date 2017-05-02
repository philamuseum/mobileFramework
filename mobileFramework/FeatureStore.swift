//
//  AssetStore.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/2/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

enum FeatureStoreError: Error {
    case fileNotFound
    case ParsingError
}

enum FeatureStoreType : Int {
    case beacon
    case location
}

class FeatureStore {
    
    static var sharedInstance = FeatureStore()
    
    private(set) var assets = [Any]()
    
    func load(filename: String, ext: String = "json", type: FeatureStoreType, completion: () -> Void) throws {
        
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
