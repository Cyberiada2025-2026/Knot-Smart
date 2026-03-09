@tool
extends Node3D
class_name ChunkManager


var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var chunk_generator: ChunkGenerator

var active_chunks: Dictionary[Vector2i, MeshInstance3D] = {}

var chunk_unit_size: float:
	get: return world_generation_params.chunk_size * world_generation_params.tile_size

func clear_inactive_chunks(render_position = null) -> void:
		
	if render_position == null:
		for child in find_children("", "MeshInstance3D"):
			child.free()
		active_chunks.clear()
		return

	var center_coord = Vector2i(
		floor(render_position.x / chunk_unit_size),
		floor(render_position.z / chunk_unit_size)
	)
	
	for coord in active_chunks.keys():
		var diff = (coord - center_coord).abs()
		if diff.x > world_display_params.render_distance or diff.y > world_display_params.render_distance:
			if is_instance_valid(active_chunks[coord]):
				active_chunks[coord].queue_free()
				remove_child(active_chunks[coord])
			active_chunks.erase(coord)
			
func generate_chunks(blueprint, render_position = null) -> void:
	chunk_generator = ChunkGenerator.new(world_generation_params, world_display_params)
	clear_inactive_chunks(render_position)
	if render_position != null:
		var center_chunk = (render_position / chunk_unit_size).floor()
		
		var start_x = max(0, int(center_chunk.x) - world_display_params.render_distance)
		var end_x   = min(world_generation_params.map_size, int(center_chunk.x) + world_display_params.render_distance + 1)

		var start_z = max(0, int(center_chunk.z) - world_display_params.render_distance)
		var end_z   = min(world_generation_params.map_size, int(center_chunk.z) + world_display_params.render_distance + 1)
		
		for x in range(start_x, end_x):
			for z in range(start_z, end_z):
				var coord = Vector2i(x, z)
				if not active_chunks.has(coord):
					var chunk_node = chunk_generator.create_chunk_instance(coord, blueprint)
		
					add_child(chunk_node)
					chunk_node.owner = get_tree().edited_scene_root
					
					active_chunks[coord] = chunk_node
					
	else:
		for x in world_generation_params.map_size:
			for z in world_generation_params.map_size:
				var coord = Vector2i(x, z)
				var chunk_node = chunk_generator.create_chunk_instance(coord, blueprint)
				add_child(chunk_node)
				chunk_node.owner = get_tree().edited_scene_root
					
				active_chunks[coord] = chunk_node
