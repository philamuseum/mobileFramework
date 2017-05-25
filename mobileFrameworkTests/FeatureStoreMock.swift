//
//  FeatureStoreMock.swift
//  mobileFramework
//
//  Created by Peter.Alt on 5/25/17.
//  Copyright © 2017 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

public class FeatureStoreMock : FeatureStore {
    
    public func addAsset(asset: Any) {
        self.assets.append(asset)
    }
}
