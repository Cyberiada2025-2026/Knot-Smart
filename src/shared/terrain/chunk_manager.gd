@tool
class_name ChunkManager
extends Node3D

@export var player: Player

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var active_chunks: Dictionary[Vector2i, Node3D] = {}

var active_chunks_start: Vector2i = Vector2i.ZERO
var active_chunks_end: Vector2i = -Vector2i.ONE

var is_active: bool = false

var blueprint: TerrainBlueprint

var chunk_unit_size: float:
	get:
		return world_generation_params.chunk_size * world_generation_params.tile_size


func clear_inactive_chunks() -> void:
	is_active = false
	active_chunks.clear()
	for child in get_children():
		child.queue_free()


func begin_generation(
	_blueprint: TerrainBlueprint,
	_world_display_params: WorldDisplayParams,
	_world_generation_params: WorldGenerationParams
):
	blueprint = _blueprint
	world_display_params = _world_display_params
	world_generation_params = _world_generation_params
	is_active = true
	print("ChunkManager: Is active")


func update_active_chunks_borders() -> void:
	var render_position: Vector2i = Vector2i.ZERO
	var render_distance: Vector2i = Vector2i(
		world_generation_params.map_size, world_generation_params.map_size
	)

	if player != null and player.is_inside_tree():
		var player_position = player.player_physics.global_position
		render_position = Vector2i(player_position.x, player_position.z)
		render_distance = Vector2i(
			world_display_params.render_distance, world_display_params.render_distance
		)

	var current_chunk: Vector2i = floor(render_position / chunk_unit_size)

	var new_start: Vector2i = (current_chunk - render_distance).clampi(
		0, world_generation_params.map_size
	)
	var new_end: Vector2i = (current_chunk + render_distance + Vector2i.ONE).clampi(
		0, world_generation_params.map_size
	)

	if new_start != active_chunks_start or new_end != active_chunks_end:
		active_chunks_start = new_start
		active_chunks_end = new_end

		print("ChunkManager: [Current Chunk] [Render Start] [Render End]")
		prints(current_chunk, active_chunks_start, active_chunks_end)

		update_active_chunks()


func update_active_chunks() -> void:
	print("ChunkManager: Updating visible chunks")
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
				var chunk_generator = ChunkGenerator.new(
					world_generation_params, world_display_params
				)
				var chunk_node = chunk_generator.create_chunk_instance(coord, blueprint, self)
				active_chunks[coord] = chunk_node


func _process(_delta: float) -> void:
	if is_active:
		update_active_chunks_borders()
