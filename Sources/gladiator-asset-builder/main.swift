import Foundation
import ArgumentParser
import GladiatorAssetManager
import PNG

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
            var (rgbas, (x, y)) = try PNG.rgba(path: png, of: UInt16.self)
            
            var data = Data()
            
            // Add width
            print("Appending Texture data with width - \(x)")
            data = data + Data(bytes: &x, count: MemoryLayout<Int>.size)
            // Add height
            print("Appending Texture data with height - \(y)")
            data = data + Data(bytes: &y, count: MemoryLayout<Int>.size)
            
            // Add raw pixels
            print("Appending Texture data with \(rgbas.count) pixels")
            
            for rgbaLine in rgbas.chunked(into: x) {
                var lineData = Data()
                for rgba in rgbaLine {
                    var pixelData = Data()
                    // Add RGBA
                    pixelData = pixelData + withUnsafeBytes(of: rgba.r) { Data($0) }
                    pixelData = pixelData + withUnsafeBytes(of: rgba.g) { Data($0) }
                    pixelData = pixelData + withUnsafeBytes(of: rgba.b) { Data($0) }
                    pixelData = pixelData + withUnsafeBytes(of: rgba.a) { Data($0) }
                    // Add to lineData
                    lineData = lineData + pixelData
                }
                data = data + lineData
            }
            
            let texture = Texture(sourceData: data)
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
            
            let width = rawData.subdata(in: 0..<MemoryLayout<Int>.size).withUnsafeBytes {
                $0.load(as: Int.self)
            }
            let height = rawData.subdata(in: MemoryLayout<Int>.size..<MemoryLayout<Int>.size*2).withUnsafeBytes {
                $0.load(as: Int.self)
            }
            
            let pixelsData = rawData.subdata(in: MemoryLayout<Int>.size*2..<rawData.endIndex)
            
            var rgbas = [PNG.RGBA<UInt16>]()
            
            for y in 0..<height {
                var line = [PNG.RGBA<UInt16>]()
                for x in 0..<width {
                    func getPixelPropertyValue(i: Int, data: Data) -> UInt16 {
                        data.subdata(in: MemoryLayout<UInt16>.size*i..<MemoryLayout<UInt16>.size*(i+1)).withUnsafeBytes {
                            $0.load(as: UInt16.self)
                        }
                    }
                    func getPixelProperties(data: Data) -> [UInt16] {
                        return [
                            getPixelPropertyValue(i: 0, data: data),
                            getPixelPropertyValue(i: 1, data: data),
                            getPixelPropertyValue(i: 2, data: data),
                            getPixelPropertyValue(i: 3, data: data),
                        ]
                    }
                    let i = (x+1)*(y+1)-1
                    let pixelData = pixelsData.subdata(in: MemoryLayout<UInt16>.size*i*4..<MemoryLayout<UInt16>.size*(i+1)*4)
                    let pixelProps = getPixelProperties(data: pixelData)
                    let pixel = PNG.RGBA<UInt16>(pixelProps[0], pixelProps[1], pixelProps[2], pixelProps[3])
                    line.append(pixel)
                }
                rgbas = rgbas + line
                print("Line \(y) is done!")
            }
            
            try PNG.encode(rgba: rgbas, size: (width, height), as: .rgba16, path: outputOptions.outputPath)
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
