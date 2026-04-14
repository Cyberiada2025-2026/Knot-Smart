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

	var get_step = func(tx: int, tz: int):
		var raw = world_generation_params.noise.get_noise_2d(tx, tz)
		var norm = (raw + 1) / 2.0
		return floor((norm + world_generation_params.height_displacement) * world_generation_params.map_height)

	const R_SLOPE = {"N": 0.0, "E": PI/2.0, "S": PI, "W": 1.5*PI}
	const R_INNER = {"NE": 0.0, "SE": PI/2.0, "SW": PI, "NW": 1.5*PI}
	const R_OUTER = {"NE": 0.0, "SE": PI/2.0, "SW": PI, "NW": 1.5*PI}

	for z in blueprint.world_size:
	
		var is_transformation_strip = (z % 2 != 0) 
		
		var current_step = floor(z / 2.0)
		var final_height = current_step * world_generation_params.tile_height

		for x in blueprint.world_size:
			var coord = Vector2i(x, z)
			
			var selected_mesh : Mesh
			var rotation_y : float
			var rule : TileInfo.PlacementRule
			
			if is_transformation_strip:
				selected_mesh = mesh_slope
				rotation_y = 0.0 
				rule = TileInfo.PlacementRule.SLOPE_Z
			else:
				selected_mesh = mesh_flat
				rotation_y = 0.0
				rule = TileInfo.PlacementRule.FLAT

			var mi = MeshInstance3D.new()
			mi.mesh = selected_mesh
			mi.rotation.y = rotation_y
			mi.position = Vector3(0, final_height, 0) 

			var tile = blueprint.data[coord]
			tile.height = final_height
			tile.placement_rule = rule
			tile.objects.clear()
			tile.objects.append(mi)
