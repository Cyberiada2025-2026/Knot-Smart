@tool
class_name MapInstancer
extends Resource

var scene_path: String = "user://terrain/"
var chunk_path = "user://terrain/chunks/"
var scene_name: String = "generated_map"
var root_name: String = "Map"

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams
var blueprint: MapTileData

var shape_cache: Dictionary = {}


func _init(manager: MapRenderer):
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params
	world_display_params = manager.world_display_params


func set_owner_recursive(node: Node, owner_node: Node):
	if node != owner_node and node.owner == null:
		node.owner = owner_node
	for child in node.get_children():
		set_owner_recursive(child, owner_node)

func create_map_instance(map_path: String = scene_path) -> void:
	scene_path = map_path
	if FileAccess.file_exists(scene_path):
		var dir = DirAccess.open(scene_path.get_base_dir())
		if dir:
			var file_name = scene_path.get_file()
			dir.remove(file_name)

	var root_node := Node3D.new()
	root_node.name = root_name

	var chunks_node := Node3D.new()
	chunks_node.name = "Chunks"
	root_node.add_child(chunks_node)
	chunks_node.owner = root_node

	for x in world_generation_params.map_size:
		for z in world_generation_params.map_size:
			var chunk_final_path = chunk_path + "chunk_%d_%d.tscn" % [x, z]
			create_chunk_scene(Vector2i(x, z), chunk_final_path)

			var chunk = ResourceLoader.load(chunk_final_path)
			var chunk_node = chunk.instantiate()
			chunks_node.add_child(chunk_node)
			chunk_node.owner = root_node

	var scene = PackedScene.new()
	if not DirAccess.dir_exists_absolute(scene_path):
		DirAccess.make_dir_recursive_absolute(scene_path)
	scene.take_over_path(scene_path + scene_name + ".tscn")

	var result = scene.pack(root_node)
	if result == OK:
		var error = ResourceSaver.save(scene, scene_path + scene_name + ".tscn")
		if error != OK:
			push_error("An error occurred while saving the map to disk.")


func create_chunk_scene(chunk_coord: Vector2i, chunk_final_path: String) -> void:
	if FileAccess.file_exists(chunk_final_path):
		var dir = DirAccess.open(chunk_final_path.get_base_dir())
		if dir:
			var file_name = chunk_final_path.get_file()
			dir.remove(file_name)

	var chunk_node = Node3D.new()
	chunk_node.name = "ChunkX%dZ%d" % [chunk_coord.x, chunk_coord.y]

	chunk_node.position = Vector3(
		chunk_coord.x * world_generation_params.get_chunk_unit_size(),
		0,
		chunk_coord.y * world_generation_params.get_chunk_unit_size()
	)

	var chunk_start = chunk_coord * world_generation_params.chunk_size

	for x in world_generation_params.chunk_size:
		for z in world_generation_params.chunk_size:
			var world_coord = chunk_start + Vector2i(x, z)
			if not blueprint.data.has(world_coord):
				continue

			var tile_info = blueprint.data[world_coord]

			for data_node in tile_info.objects:
				var mi = data_node.duplicate()
				mi.name = "Tile_%d_%d" % [x, z]

				var local_pos = Vector3(
					x * world_generation_params.tile_size, tile_info["height"] + mi.position.y, z * world_generation_params.tile_size
				)
				mi.position = local_pos

				chunk_node.add_child(mi)
				mi.owner = chunk_node
				set_owner_recursive(mi, chunk_node)


	var scene = PackedScene.new()
	var directory_path = chunk_final_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(directory_path):
		DirAccess.make_dir_recursive_absolute(directory_path)

	var error = scene.pack(chunk_node)
	if error == OK:
		ResourceSaver.save(scene, chunk_final_path)
	else:
		push_error("Failed to pack chunk scene: ", error)

	chunk_node.queue_free()
