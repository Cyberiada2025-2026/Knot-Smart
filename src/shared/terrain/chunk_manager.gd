@tool
extends Node3D
class_name ChunkManager

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var chunk_generator: ChunkGenerator

var active_chunks: Dictionary[Vector2i, Node3D] = {}
var can_generate = false
var blueprint: TerrainBlueprint

var chunk_unit_size: float:
	get: return world_generation_params.chunk_size * world_generation_params.tile_size

func clear_inactive_chunks(render_position = null) -> void:
	if render_position == null:
		can_generate = false
		for child in get_children():
			child.free()
		active_chunks.clear()
		return

	var center_coord = Vector2i(
		floor(render_position.x / chunk_unit_size),
		floor(render_position.z / chunk_unit_size)
	)
	
	for coord in active_chunks.keys():
		var diff = (coord - center_coord).abs()
		if max(diff.x, diff.y) > world_display_params.render_distance:
			if is_instance_valid(active_chunks[coord]):
				active_chunks[coord].queue_free()
				remove_child(active_chunks[coord])
			active_chunks.erase(coord)
func _get_render_position() -> Variant:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		print("position",players[0].player_physics.position)
		return players[0].player_physics.position
	return null
		
func begin_generation(b,d,g):
	can_generate = true
	blueprint = b
	world_display_params = d
	world_generation_params = g
	generate_chunks()
	print("can run")
	
func generate_chunks() -> void:
	print("achunkgen")
	chunk_generator = ChunkGenerator.new(world_generation_params, world_display_params)
	var render_position = _get_render_position()
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
					var chunk_node = chunk_generator.create_chunk_instance(coord, blueprint, self)
										
					active_chunks[coord] = chunk_node
					
	else:
		for x in world_generation_params.map_size:
			for z in world_generation_params.map_size:
				var coord = Vector2i(x, z)
				var chunk_node = chunk_generator.create_chunk_instance(coord, blueprint, self)
					
				active_chunks[coord] = chunk_node
				
#func _process(_delta: float) -> void:
#	if can_generate == true:
#		generate_chunks()
