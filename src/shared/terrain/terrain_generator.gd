@tool
class_name TerrainGenerator
extends Node

var world_generation_params: WorldGenerationParams
var blueprint: MapTileData


func run_generation(manager: GridGenerationPipeline) -> void:
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params

	for x in blueprint.world_size:
		for z in blueprint.world_size:
			var coord = Vector2i(x, z)

			var raw_val = world_generation_params.noise.get_noise_2d(x, z)
			var normalized = (raw_val + 1) / 2.0
			var step_index = floor(
				(
					(normalized + world_generation_params.height_displacement)
					* world_generation_params.map_height
				)
			)
			var final_height = step_index * world_generation_params.tile_height

			blueprint.data[coord].height = final_height
