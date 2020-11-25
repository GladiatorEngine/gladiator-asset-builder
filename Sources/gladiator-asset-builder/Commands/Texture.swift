//
//  Texture.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation
import ArgumentParser
import AssetManager

extension GladiatorAssetBuilder {
    struct Texture: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Work with textures",
            subcommands: [Build.self, ToPNG.self]
        )
    }
}

extension GladiatorAssetBuilder.Texture {
    struct Build: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Builds GEA-texture for the engine")

        @Option(name: .shortAndLong, help: "PNG texture path")
        var png: String
        
        @OptionGroup
        var options: OutputOptions

        mutating func run() throws {
            let texture = Texture(sourceData: try Data(contentsOf: URL(fileURLWithPath: png)))
            AssetManager.saveAsset(path: options.outputPath, asset: texture)
        }
    }
    
    struct TextureOptions: ParsableArguments {
        @Argument(help: "Texture path")
        var texture: String
    }
    
    struct ToPNG: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Converts GEA-texture to PNG")

        @OptionGroup
        var options: TextureOptions
        
        @OptionGroup
        var outputOptions: OutputOptions

        mutating func run() throws {
            var manager = AssetManager()
            try manager.loadTextureAsset(path: options.texture)
            
            let rawData = manager.textures[0].assetData()
            
            try rawData.write(to: URL(fileURLWithPath: outputOptions.outputPath))
        }
    }
}
