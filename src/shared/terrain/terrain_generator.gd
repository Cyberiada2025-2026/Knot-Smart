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

			var get_step = func(tx: int, tz: int):
				var raw = world_generation_params.noise.get_noise_2d(tx, tz)
				var norm = (raw + 1) / 2.0
				return floor((norm + world_generation_params.height_displacement) * world_generation_params.map_height)

			var current_step = get_step.call(x, z)

			var h_n = get_step.call(x, z - 1) # North
			var h_s = get_step.call(x, z + 1) # South
			var h_e = get_step.call(x + 1, z) # East
			var h_w = get_step.call(x - 1, z) # West

			var up_n = h_n > current_step
			var up_s = h_s > current_step
			var up_e = h_e > current_step
			var up_w = h_w > current_step

			var mesh_to_use : Mesh
			var mesh_rotation : float = 0.0

			if (up_n or up_s) and (up_e or up_w):
				mesh_to_use = assets.mesh_corner
				if up_n and up_e: mesh_rotation = PI / 2
				elif up_e and up_s: mesh_rotation = PI
				elif up_s and up_w: mesh_rotation = 1.5 * PI
				else: mesh_rotation = 0.0
				
			elif up_n or up_s or up_e or up_w:
				mesh_to_use = 
				# Example rotation logic for a slope
				if up_n: mesh_rotation = 0.0
				elif up_e: mesh_rotation = PI / 2
				elif up_s: mesh_rotation = PI
				elif up_w: mesh_rotation = 1.5 * PI
				
			else:
				mesh_to_use = assets.mesh_flat

			blueprint.data[coord].height = final_height
