//
//  Other.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation
import AssetManager

// MARK: - Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Errors

enum AssetBuilderError: Error {
    case assetNotFound(type: AssetType, id: Int)
}
