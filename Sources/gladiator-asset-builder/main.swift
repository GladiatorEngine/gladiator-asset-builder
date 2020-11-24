import Foundation
import ArgumentParser
import GladiatorAssetManager

struct GladiatorAssetBuilder: ParsableCommand {
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "Allows to create Gladiator Engine Asset Packs and more",

        // Commands can define a version for automatic '--version' support.
        version: "1.0.0",
        
        subcommands: [Texture.self, Pack.self])
}

struct OutputOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "Output path")
    var outputPath: String = "output.gea"
}

extension GladiatorAssetBuilder {
    struct Texture: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Work with textures",
            subcommands: [Build.self, ToPNG.self]
        )
    }
    
    struct Pack: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Work with pack",
            subcommands: [Build.self, Index.self, ExtractTexture.self]
        )
    }
}

// MARK: - Texture

extension GladiatorAssetBuilder.Texture {
    struct Build: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Builds GEA-texture for the engine")

        @Option(name: .shortAndLong, help: "PNG texture path")
        var png: String
        
        @OptionGroup
        var options: OutputOptions

        mutating func run() throws {
            let texture = Texture(sourceData: try Data(contentsOf: URL(fileURLWithPath: png)))
            GladiatorAssetManager.saveAsset(path: options.outputPath, type: .texture, data: texture.assetData())
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
            var manager = GladiatorAssetManager()
            try manager.loadTextureAsset(path: options.texture)
            
            let rawData = manager.textures[0].assetData()
            
            try rawData.write(to: URL(fileURLWithPath: outputOptions.outputPath))
        }
    }
}

// MARK: - Pack

extension GladiatorAssetBuilder.Pack {
    struct Build: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Builds pack of assets for the engine")

        @Argument(help: "Files to work on")
        var files: [String] = []
        
        @OptionGroup
        var options: OutputOptions

        mutating func run() throws {
            let assets = try files.map { file -> RawAsset in
                let d = try Data(contentsOf: URL(fileURLWithPath: file))
                return RawAsset(rawData: d.subdata(in: 0..<d.endIndex-64))
            }
            
            let pack = GladiatorAssetManager.buildAssetPackData(assets: assets)

            GladiatorAssetManager.saveAsset(path: options.outputPath, type: .pack, data: pack)
        }
    }
    
    struct PackOptions: ParsableArguments {
        @Argument(help: "Pack path")
        var pack: String
    }
    
    struct Index: ParsableCommand {
        @OptionGroup
        var options: PackOptions

        mutating func run() throws {
            var manager = GladiatorAssetManager()
            try manager.loadAssetPack(path: options.pack)
            
            print("Textures: ")
            for (i, texture) in manager.textures.enumerated() {
                print("Texture #\(i) - \(texture.assetData().count) bytes")
            }
        }
    }
    
    struct ExtractTexture: ParsableCommand {
        @OptionGroup
        var outputOptions: OutputOptions
        
        @OptionGroup
        var options: PackOptions
        
        @Argument(help: "Texture ID")
        var textureID: Int

        mutating func run() throws {
            var manager = GladiatorAssetManager()
            try manager.loadAssetPack(path: options.pack)
            
            if let texture = manager.textures[safe: textureID] {
                GladiatorAssetManager.saveAsset(path: outputOptions.outputPath, asset: texture)
            } else {
                throw AssetBuilderError.assetNotFound(type: .texture, id: textureID)
            }
        }
    }
}

GladiatorAssetBuilder.main()

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
