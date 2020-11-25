//
//  RawAsset.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation
import AssetManager

struct RawAsset: Asset {
    private var data: Data
    private var asset: AssetType = .texture
    
    init(sourceData: Data) {
        self.data = sourceData
    }
    
    init(rawData: Data) {
        self.asset = AssetType(rawValue: rawData.subdata(in: 0..<1).withUnsafeBytes {$0.pointee}) ?? .texture
        self.data = rawData.subdata(in: 1..<rawData.endIndex)
    }
    
    func assetData() -> Data {
        return self.data
    }
    
    func assetType() -> AssetType {
        return self.asset
    }
}
