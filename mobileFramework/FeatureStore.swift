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

class FeatureStore {
    
    private(set) var assets = [Any]()
    
    func load(filename: String, ext: String = "json", completion: () -> Void) throws {
        
        let bundle = Bundle(for: type(of: self))
        guard let fileURL = bundle.url(forResource: filename, withExtension: ext)
            else { throw FeatureStoreError.fileNotFound }
        
        do {
            let localData = try Data(contentsOf: fileURL)
            let JSON = try JSONSerialization.jsonObject(with: localData, options: [])
            
            self.assets.append(JSON)
            completion()
        } catch {
            throw FeatureStoreError.ParsingError
        }
        
    }
    
    
//    do {
//    if let data = data,
//    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//    let blogs = json["blogs"] as? [[String: Any]] {
//    for blog in blogs {
//    if let name = blog["name"] as? String {
//    names.append(name)
//    }
//    }
//    }
//    } catch {
//    print("Error deserializing JSON: \(error)")
//    }
//    
    
}
