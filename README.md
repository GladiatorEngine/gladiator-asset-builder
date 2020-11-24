# Gladiator Asset Builder

**Gladiator Asset Builder** is an CLI application which aims to help to work with Gladiator Engine Assets (GEAs).

## Installation
### Homebrew
Installation with Homebrew is easy as usual:
```shell
brew install GladiatorEngine/tap/gladiator-asset-builder
```
### Compile rom sources
To compile from sources, you should do almost the same as Homebrew does in the background.
#### Debug
```shell
swift build
```
#### Release
```shell
swift build --configuration release --disable-sandbox
```
## Usage
Almost everything what you need is written in `--help` instructions, but there are some use cases below.
### Create assets pack with textures
```shell
gladiator-asset-builder texture build --png texture01.png -o texture_01.gea
gladiator-asset-builder texture build --png texture02.png -o texture_02.gea
gladiator-asset-builder texture build --png texture03.png -o texture_03.gea
gladiator-asset-builder pack build texture01.gea texture02.gea texture03.gea -o pack.gea
```
### Index textures in assets pack and extract one of them
```shell
gladiator-asset-builder pack index pack.gea
# OUTPUT:
## Textures: 
## Texture #0 - 201046 bytes
## Texture #1 - 201046 bytes
## Texture #2 - 201046 bytes
gladiator-asset-builder pack extract-texture -o texture_extracted.gea pack.gea 0
```
### Create model from vertices
```shell
gladiator-asset-builder model build --vertices vertices.json -o model.gea
```
#### verticies.json
```json
[
    [-0.5, 0.5, 0.5, 1],
    [-0.5, -0.5, 0.5, 1],
    [0.5, -0.5, 0.5, 1],
    [0.5, 0.5, 0.5, 1],
    [-0.5, 0.5,-0.5, 1],
    [-0.5, -0.5, -0.5, 1],
    [0.5, -0.5, -0.5, 1],
    [0.5, 0.5, -0.5, 1]
]
```
### Export model to verices JSON
```shell
gladiator-asset-builder model to-vertices-json model.gea --output-path vertices_exported.json
```
