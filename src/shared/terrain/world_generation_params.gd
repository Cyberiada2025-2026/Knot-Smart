class_name WorldGenerationParams
extends Resource

## The total width and depth of the map in world units.
@export_range(4, 2048, 4) var map_size := 64

@export_range(4, 2048, 4.0) var map_height := 64.0

## The size of an individual data chunk. Smaller chunks allow for 
## more granular optimization but increase draw calls.
@export_range(4, 32, 4) var chunk_size := 4

## The horizontal dimensions of a single tile or face within the mesh.
@export_range(1, 100, 1) var tile_size := 8

@export_range(1, 100, 0.5) var tile_height := 8.0

## The noise algorithm used to calculate elevation.
@export var noise: FastNoiseLite
