@tool
class_name ChunkGenerator
extends Node3D

@export_tool_button("Clean") var clean_action = clear_chunks

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var active_chunks: Dictionary = {}

func clear_chunks(render_position = null) -> void:
	
	var chunk_offset = world_generation_params.chunk_size * world_generation_params.tile_size
	
	if render_position == null:
		for child in find_children("", "MeshInstance3D"):
			child.free()
		active_chunks.clear()
		return

	var center_coord = Vector2i(
		floor(render_position.x / chunk_offset),
		floor(render_position.y / chunk_offset)
	)
	
	for coord in active_chunks.keys():
		var diff = (coord - center_coord).abs()
		if diff.x > world_display_params.render_distance or diff.y > world_display_params.render_distance:
			if is_instance_valid(active_chunks[coord]):
				active_chunks[coord].queue_free()
				remove_child(active_chunks[coord])
			active_chunks.erase(coord)
func generate_chunks(blueprint, render_position = null) -> void:
	clear_chunks(render_position)
	if render_position != null:
		var chunk_offset = world_generation_params.chunk_size * world_generation_params.tile_size
		var clampedx = range(max(floor(render_position.x / chunk_offset)-world_display_params.render_distance,0),min(floor(render_position.x / chunk_offset)+world_display_params.render_distance,world_generation_params.map_size))
		var clampedz = range(max(floor(render_position.z / chunk_offset)-world_display_params.render_distance,0),min(floor(render_position.z / chunk_offset)+world_display_params.render_distance,world_generation_params.map_size))
		for x in clampedx:
			for z in clampedz:
				var coord = Vector2i(x, z)
				if not active_chunks.has(coord):
					create_chunk_node(coord, blueprint)
	else:
		for x in world_generation_params.map_size:
			for z in world_generation_params.map_size:
				var coord = Vector2i(x, z)
				create_chunk_node(coord, blueprint)
			
	print("ChunkGenerator: Active chunks: ", active_chunks.size())

func create_chunk_node(chunk_coord: Vector2i, blueprint: Dictionary) -> void:
	var chunk = MeshInstance3D.new()
	
	chunk.name = "ChunkX%dZ%d" % [chunk_coord.x, chunk_coord.y]
	add_child(chunk)
	chunk.owner = get_tree().edited_scene_root
	
	var chunk_offset = world_generation_params.chunk_size * world_generation_params.tile_size
	chunk.global_position = Vector3(chunk_coord.x * chunk_offset, 0, chunk_coord.y * chunk_offset)
	
	var mesh = generate_chunk_mesh(chunk_coord, blueprint)
	chunk.mesh = mesh
	
	chunk.create_trimesh_collision()
	
	if world_display_params.terrain_material:
		chunk.material_override = world_display_params.terrain_material
		
	active_chunks[chunk_coord] = chunk

func generate_chunk_mesh(chunk_coord: Vector2i, blueprint: Dictionary) -> Mesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var chunk_size = world_generation_params.chunk_size
	var tile_size = world_generation_params.tile_size

	for x in chunk_size:
		for z in chunk_size:
			var vertices: Array[Vector3] = []
			for i in 2:
				for j in 2:
					var vertex_position = Vector3(x + j, 0, z + i) * tile_size
					var height_sample_position = chunk_coord * chunk_size + Vector2i(x, z)
					vertex_position.y = get_height_from_blueprint(height_sample_position + Vector2i(j, i), blueprint)
					vertices.push_back(vertex_position)
			
			add_quad(st, vertices)
	# Finalize mesh
	st.generate_tangents()
	return st.commit()

func add_triangle(st: SurfaceTool, vertices: Array):
	var normal = ((vertices[2] - vertices[0]).cross(vertices[1] - vertices[0])).normalized()
	for v in vertices:
		var uv = Vector2(v.x, v.z) / float(world_generation_params.tile_size)
		
		st.set_normal(normal)
		st.set_uv(uv)
		st.add_vertex(v)	
		
func add_quad(st: SurfaceTool, vertices: Array[Vector3]):
	add_triangle(st, [vertices[0],vertices[1],vertices[3]])
	add_triangle(st, [vertices[0],vertices[3],vertices[2]])

func get_height_from_blueprint(coord: Vector2i, blueprint: Dictionary) -> float:
	if blueprint.has(coord):
		return blueprint[coord].height
	elif blueprint.has(coord - Vector2i(0,1)):
		return blueprint[coord - Vector2i(0,1)].height
	elif blueprint.has(coord - Vector2i(1,0)):
		return blueprint[coord - Vector2i(1,0)].height
	elif blueprint.has(coord - Vector2i(1,1)):
		return blueprint[coord - Vector2i(1,1)].height
	return 0.0
	
