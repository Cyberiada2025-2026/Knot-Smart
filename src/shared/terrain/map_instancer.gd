@tool
class_name MapInstancer
extends Resource

var SCENE_DIR: String = "scenes/map/"
var SCENE_NAME: String = "generated_map"
var ROOT_NAME: String = "Map"

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams
var blueprint: MapTileData

var shape_cache: Dictionary = {}

func _init(manager: MapRenderer):
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params
	world_display_params = manager.world_display_params

func create_map_instance(MAP_DIR: String = SCENE_DIR) -> void:
	SCENE_DIR = MAP_DIR
	var root_node := Node3D.new()
	root_node.name = ROOT_NAME
	
	var chunks_node := Node3D.new()
	chunks_node.name = "Chunks"
	root_node.add_child(chunks_node)	
	chunks_node.owner = root_node
	
	for x in world_generation_params.map_size:
		for z in world_generation_params.map_size:
			var CHUNK_PATH = "res://" + SCENE_DIR + "chunks/chunk_%d_%d.tscn" % [x, z]
			create_chunk_scene(Vector2i(x,z), CHUNK_PATH)
			
			var chunk = ResourceLoader.load(CHUNK_PATH)
			var chunk_node = chunk.instantiate()
			chunks_node.add_child(chunk_node)
			chunk_node.owner = root_node
	
	var scene = PackedScene.new()
	scene.take_over_path("res://" + SCENE_DIR + SCENE_NAME + ".tscn")

	# Only `node` and `body` are now packed.
	var result = scene.pack(root_node)
	if result == OK:
		var error = ResourceSaver.save(scene, "res://" + SCENE_DIR + SCENE_NAME + ".tscn")
		if error != OK:
			push_error("An error occurred while saving the map to disk.")


func create_chunk_scene(chunk_coord: Vector2i, CHUNK_PATH: String) -> void:
	var chunk_node = Node3D.new()
	chunk_node.name = "ChunkX%dZ%d" % [chunk_coord.x, chunk_coord.y]
	chunk_node.position = Vector3(
		chunk_coord.x * world_generation_params.get_chunk_unit_size(),
		0,
		chunk_coord.y * world_generation_params.get_chunk_unit_size()
	)

	var mesh_groups: Dictionary = {}
	
	var chunk_start = chunk_coord * world_generation_params.chunk_size
	for x in world_generation_params.chunk_size:
		for z in world_generation_params.chunk_size:
			var world_coord = chunk_start + Vector2i(x, z)
			if not blueprint.data.has(world_coord): continue
			
			var tile_info = blueprint.data[world_coord]
			for data_node in tile_info.objects:
				var m = data_node.mesh
				if not mesh_groups.has(m):
					mesh_groups[m] = []
				
				var pos = Vector3(x * world_generation_params.tile_size, tile_info.height, z * world_generation_params.tile_size)
				var t = Transform3D(data_node.basis, pos)
				mesh_groups[m].append(t)

	for mesh_key in mesh_groups.keys():
		var transforms = mesh_groups[mesh_key]
		
		var mmi = MultiMeshInstance3D.new()
		mmi.multimesh = MultiMesh.new()
		mmi.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		mmi.multimesh.mesh = mesh_key
		mmi.multimesh.instance_count = transforms.size()
		
		for i in range(transforms.size()):
			mmi.multimesh.set_instance_transform(i, transforms[i])
			
		chunk_node.add_child(mmi)
		mmi.owner = chunk_node
		
		if world_display_params.terrain_material:
			mmi.material_override = world_display_params.terrain_material
		
		if not shape_cache.has(mesh_key):
			shape_cache[mesh_key] = mesh_key.create_trimesh_shape()
		for t in transforms:
			var sb = StaticBody3D.new()
			var col = CollisionShape3D.new()
			col.shape = shape_cache[mesh_key]
			
			sb.add_child(col)
			mmi.add_child(sb)
			
			sb.transform = t
			sb.owner = chunk_node
			col.owner = chunk_node

	var scene = PackedScene.new()
	scene.pack(chunk_node)
	ResourceSaver.save(scene, CHUNK_PATH)
