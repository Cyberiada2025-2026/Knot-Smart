@tool
class_name TerrainGenerator
extends Node

var world_generation_params: WorldGenerationParams
var blueprint: MapTileData

@export var mesh_flat: Mesh
@export var mesh_slope: Mesh
@export var mesh_corner: Mesh

func run_generation(manager: GridGenerationPipeline) -> void:
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params

	var get_step = func(tx: int, tz: int):
		var raw = world_generation_params.noise.get_noise_2d(tx, tz)
		var norm = (raw + 1) / 2.0
		return floor((norm + world_generation_params.height_displacement) * world_generation_params.map_height)

	for x in blueprint.world_size:
		for z in blueprint.world_size:
			var coord = Vector2i(x, z)
			var current_step = get_step.call(x, z)
			
			var final_height = current_step * world_generation_params.tile_height
			
			var h_n = get_step.call(x, z - 1)
			var h_s = get_step.call(x, z + 1)
			var h_e = get_step.call(x + 1, z)
			var h_w = get_step.call(x - 1, z)

			var up_n = h_n > current_step
			var up_s = h_s > current_step
			var up_e = h_e > current_step
			var up_w = h_w > current_step

			var selected_mesh : Mesh = mesh_flat
			var rotation_y : float = 0.0
			var rule = TileInfo.PlacementRule.FLAT

			var is_horizontal = up_e or up_w
			var is_vertical = up_n or up_s

			if is_horizontal and is_vertical:
				selected_mesh = mesh_corner
				rule = TileInfo.PlacementRule.BLOCKED
			elif is_horizontal or is_vertical:
				selected_mesh = mesh_slope
				rule = TileInfo.PlacementRule.SLOPE_X if is_horizontal else TileInfo.PlacementRule.SLOPE_Z
			else:
				selected_mesh = mesh_flat
				rule = TileInfo.PlacementRule.FLAT

			if selected_mesh == mesh_corner:
				if up_n and up_e:   rotation_y = PI / 2     # NE
				elif up_e and up_s: rotation_y = PI          # SE
				elif up_s and up_w: rotation_y = 1.5 * PI    # SW
				else:               rotation_y = 0.0         # NW
			elif selected_mesh == mesh_slope:
				if up_e:    rotation_y = PI / 2
				elif up_s:  rotation_y = PI
				elif up_w:  rotation_y = 1.5 * PI
				else:       rotation_y = 0.0
			
			var mi = MeshInstance3D.new()
			mi.mesh = selected_mesh
			mi.rotation.y = rotation_y
			mi.position = Vector3.ZERO 

			var tile = blueprint.data[coord]
			tile.height = final_height
			tile.placement_rule = rule
			tile.objects.clear()
			tile.objects.append(mi)
