//
//  Model.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation
import ArgumentParser
import AssetManager

extension GladiatorAssetBuilder {
    struct Model: ParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Work with models",
            subcommands: [Build.self, ToVerticesJSON.self]
        )
    }
}

extension GladiatorAssetBuilder.Model {
    struct Build: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Builds GEA-model for the engine")

        @Option(name: .shortAndLong, help: "Vertices JSON path")
        var vertices: String
        
        @OptionGroup
        var options: OutputOptions

        mutating func run() throws {
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: vertices))
            
            let vertices = try JSONDecoder().decode([[Float]].self, from: jsonData)
            
            let model = Model(vertices: vertices)
            AssetManager.saveAsset(path: options.outputPath, asset: model)
        }
    }
    
    struct ModelOptions: ParsableArguments {
        @Argument(help: "Model path")
        var model: String
    }
    
    struct ToVerticesJSON: ParsableCommand {
        static var configuration = CommandConfiguration(abstract: "Converts GEA-model to vertices JSON file")

        @OptionGroup
        var options: ModelOptions
        
        @OptionGroup
        var outputOptions: OutputOptions

        mutating func run() throws {
            var manager = AssetManager()
            try manager.loadModelAsset(path: options.model)
            
            let data = try JSONEncoder().encode(manager.models[0].vertices)
            
            try data.write(to: URL(fileURLWithPath: outputOptions.outputPath))
        }
    }
}
