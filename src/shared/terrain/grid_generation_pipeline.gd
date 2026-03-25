@tool
class_name GridGenerationPipeline
extends Node

var world_generation_params

@export_group("Debug")
@export var debug_flag: bool

var blueprint: MapTileData

func generate_world(manager: MapRenderer) -> void:
	world_generation_params = manager.world_generation_params
	var world_size = world_generation_params.map_size * world_generation_params.chunk_size
	blueprint = MapTileData.new(world_size)

	var generators = get_children().filter(func(c): return c.has_method("execute"))

	for generator in generators:
		if debug_flag == true:
			print("TerrainManager: Starting generation for: " + generator.name)
		generator.execute(self)
		if debug_flag == true:
			print("TerrainManager: Finished generation for: " + generator.name)

	if debug_flag == true:
		print("TerrainManager: Generation completed")
