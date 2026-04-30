class_name ChunkManager
extends Node3D

var scene_dir: String = "terrain/"

var debug_flag: bool = false
var is_rendering: bool = false

var blueprint: MapTileData
var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var active_chunks: Dictionary[Vector2i, Node3D] = {}

var active_chunks_start: Vector2i
var active_chunks_end: Vector2i

var player: Player


func _init(manager: MapRenderer) -> void:
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params
	world_display_params = manager.world_display_params

	active_chunks_start = Vector2i.ZERO
	active_chunks_end = -Vector2i.ONE

	manager.add_child(self)
	self.owner = get_tree().edited_scene_root
	self.name = "ChunkManager"

	is_rendering = true

	print(self.name + ": Is active")


func clear_inactive_chunks() -> void:
	active_chunks.clear()
	for child in get_children():
		child.queue_free()


func get_player() -> Node3D:
	var players = get_tree().get_nodes_in_group("Player")
	return players[0]


func update_active_chunks_borders() -> void:
	var render_position: Vector2i = Vector2i.ZERO
	var render_distance: Vector2i = Vector2i(
		world_generation_params.map_size, world_generation_params.map_size
	)
	if player == null:
		player = get_player()
	if player != null:
		var player_position = player.player_physics.global_position
		render_position = Vector2i(player_position.x, player_position.z)
		render_distance = Vector2i(
			world_display_params.render_distance, world_display_params.render_distance
		)

	var current_chunk: Vector2i = floor(
		render_position / world_generation_params.get_chunk_unit_size()
	)

	var new_start: Vector2i = (current_chunk - render_distance).clampi(
		0, world_generation_params.map_size
	)
	var new_end: Vector2i = (current_chunk + render_distance + Vector2i.ONE).clampi(
		0, world_generation_params.map_size
	)
	if new_start != active_chunks_start or new_end != active_chunks_end:
		active_chunks_start = new_start
		active_chunks_end = new_end
		if debug_flag == true:
			print(self.name + ": [Current Chunk] [Render Start] [Render End]")
			prints(current_chunk, active_chunks_start, active_chunks_end)

		update_active_chunks()


func update_active_chunks() -> void:
	if debug_flag == true:
		print(self.name + ": Updating visible chunks")
	#remove far chunks
	for coord in active_chunks.keys():
		if coord.clamp(active_chunks_start, active_chunks_end) != coord:
			active_chunks[coord].queue_free()
			remove_child(active_chunks[coord])
			active_chunks.erase(coord)

	# add missing chunks
	for x in range(active_chunks_start.x, active_chunks_end.x):
		for y in range(active_chunks_start.y, active_chunks_end.y):
			var coord = Vector2i(x, y)
			if not active_chunks.has(coord):
				var chunk_path = "user://" + scene_dir + "chunks/chunk_%d_%d.tscn" % [x, y]
				var chunk = ResourceLoader.load(chunk_path)
				var chunk_node = chunk.instantiate()
				add_child(chunk_node)
				#if Engine.is_editor_hint() == false:
				if get_tree().edited_scene_root:
					chunk_node.owner = get_tree().edited_scene_root
				chunk_node.global_position = Vector3(
					x * world_generation_params.get_chunk_unit_size(),
					0,
					y * world_generation_params.get_chunk_unit_size()
				)

				active_chunks[coord] = chunk_node


func _process(_delta: float) -> void:
	if is_rendering == true:
		update_active_chunks_borders()
