import Foundation
import ArgumentParser
import AssetManager

struct GladiatorAssetBuilder: ParsableCommand {
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: "Allows to create Gladiator Engine Asset Packs and more",

        // Commands can define a version for automatic '--version' support.
        version: "1.0.0",
        
        subcommands: [Texture.self, Pack.self, Model.self])
}

struct OutputOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: "Output path")
    var outputPath: String = "output.gea"
}

GladiatorAssetBuilder.main()
