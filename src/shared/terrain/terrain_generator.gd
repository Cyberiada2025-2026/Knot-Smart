@tool
class_name TerrainGenerator
extends Node

var world_generation_params: WorldGenerationParams
var blueprint: MapTileData

@export var mesh_flat: Mesh
@export var mesh_slope: Mesh
@export var mesh_corner_outer: Mesh
@export var mesh_corner_inner: Mesh

func run_generation(manager: GridGenerationPipeline) -> void:
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params

	var get_step_index = func(tx: int, tz: int) -> int:
		if tx < 0 or tx >= blueprint.world_size or tz < 0 or tz >= blueprint.world_size:
			return 0
		
		var raw_val = world_generation_params.noise.get_noise_2d(tx, tz)
		var normalized = (raw_val + 1) / 2.0
		var step_index = floor(
			(
				(normalized + world_generation_params.height_displacement) 
				* world_generation_params.map_height
			)
		)
		return int(step_index)

	for z in blueprint.world_size:
		for x in blueprint.world_size:
			var coord = Vector2i(x, z)
			
			var s_curr = get_step_index.call(x, z)
			var s_n = get_step_index.call(x, z - 1)
			var s_s = get_step_index.call(x, z + 1)
			var s_e = get_step_index.call(x + 1, z)
			var s_w = get_step_index.call(x - 1, z)

			var final_height = s_curr * world_generation_params.tile_height
			
			var up_n = s_n > s_curr
			var up_s = s_s > s_curr
			var up_e = s_e > s_curr
			var up_w = s_w > s_curr
			
			var dn_n = s_n < s_curr
			var dn_s = s_s < s_curr
			var dn_e = s_e < s_curr
			var dn_w = s_w < s_curr

			var selected_mesh: Mesh = mesh_flat
			var rotation_y: float = 0.0

			if up_n and up_e:
				selected_mesh = mesh_corner_inner
				rotation_y = 0.0
			elif up_e and up_s:
				selected_mesh = mesh_corner_inner
				rotation_y = -PI/2.0
			elif up_s and up_w:
				selected_mesh = mesh_corner_inner
				rotation_y = PI
			elif up_w and up_n:
				selected_mesh = mesh_corner_inner
				rotation_y = PI/2.0
			
			elif dn_n and dn_e:
				selected_mesh = mesh_corner_outer
				rotation_y = PI
			elif dn_e and dn_s:
				selected_mesh = mesh_corner_outer
				rotation_y = PI/2.0
			elif dn_s and dn_w:
				selected_mesh = mesh_corner_outer
				rotation_y = 0.0
			elif dn_w and dn_n:
				selected_mesh = mesh_corner_outer
				rotation_y = -PI/2.0
			elif up_n:
				selected_mesh = mesh_slope
				rotation_y = 0.0
			elif up_s:
				selected_mesh = mesh_slope
				rotation_y = PI
			elif up_e:
				selected_mesh = mesh_slope
				rotation_y = -PI/2.0
			elif up_w:
				selected_mesh = mesh_slope
				rotation_y = PI/2.0
			else:
				selected_mesh = mesh_flat

			var mi = MeshInstance3D.new()
			mi.mesh = selected_mesh
			mi.rotation.y = rotation_y
			mi.position = Vector3(0, final_height, 0) 

			var tile = blueprint.data[coord]
			tile.height = final_height
			tile.objects.clear()
			tile.objects.append(mi)
