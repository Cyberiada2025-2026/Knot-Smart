@tool
class_name TerrainGenerationParams
extends Resource

@export_range(4, 2048, 4) var map_size := 64

@export_range(4, 2048, 4) var map_height := 64

@export_range(4, 32, 4) var chunk_size := 4

@export_range(1, 100, 1) var tile_size := 8

@export_range(1, 100, 1) var tile_height := 8

@export var noise: FastNoiseLite
