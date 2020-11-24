//
//  CGBased.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation
import CoreGraphics

func pixelValuesFromImage(imageRef: CGImage) -> ([UInt8], width: Int, height: Int)
{
    var width = 0
    var height = 0
    var pixelValues = [UInt8]()
    
    width = imageRef.width
    height = imageRef.height
    let bitsPerComponent = imageRef.bitsPerComponent
    let bytesPerRow = imageRef.bytesPerRow
    let totalBytes = height * bytesPerRow

    //let colorSpace = CGColorSpaceCreateDeviceGray()
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let buffer = [UInt8](repeating: 0, count: totalBytes)
    let mutablePointer = UnsafeMutablePointer<UInt8>(mutating: buffer)

    let contextRef = CGContext(data: mutablePointer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0)
    contextRef!.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))

    let bufferPointer = UnsafeBufferPointer<UInt8>(start: mutablePointer, count: totalBytes)
    pixelValues = Array<UInt8>(bufferPointer)

    return (pixelValues, width, height)
}
