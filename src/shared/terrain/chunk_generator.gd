@tool
class_name ChunkGenerator
extends Node3D

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var active_chunks: Dictionary = {}

var chunk_unit_size: float:
	get: return world_generation_params.chunk_size * world_generation_params.tile_size

func clear_chunks(render_position = null) -> void:
		
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
	clear_chunks(render_position)
	if render_position != null:
		var center_chunk = (render_position / chunk_unit_size).floor()
		
		var start_x = max(0, int(center_chunk.x) - world_display_params.render_distance)
		var end_x   = min(world_generation_params.map_size, int(center_chunk.x) + world_display_params.render_distance + 1)

		var start_z = max(0, int(center_chunk.z) - world_display_params.render_distance)
		var end_z   = min(world_generation_params.map_size, int(center_chunk.z) + world_display_params.render_distance + 1)
		
		var clamped_x = range(start_x, end_x)
		var clamped_z = range(start_z, end_z)
		
		for x in clamped_x:
			for z in clamped_z:
				var coord = Vector2i(x, z)
				if not active_chunks.has(coord):
					create_chunk_node(coord, blueprint)
					
	else:
		for x in world_generation_params.map_size:
			for z in world_generation_params.map_size:
				var coord = Vector2i(x, z)
				create_chunk_node(coord, blueprint)

func create_chunk_node(chunk_coord: Vector2i, blueprint: TerrainBlueprint) -> void:
	var chunk = MeshInstance3D.new()
	add_child(chunk)
	chunk.name = "ChunkX%dZ%d" % [chunk_coord.x, chunk_coord.y]

	chunk.global_position = Vector3(chunk_coord.x * chunk_unit_size, 0, chunk_coord.y * chunk_unit_size)
	
	var mesh = generate_chunk_mesh(chunk_coord, blueprint)
	chunk.mesh = mesh
		
	if world_display_params.terrain_material:
		chunk.material_override = world_display_params.terrain_material
		
	active_chunks[chunk_coord] = chunk
	

	chunk.owner = get_tree().edited_scene_root
	
	chunk.create_trimesh_collision()
	



func generate_chunk_mesh(chunk_coord: Vector2i, blueprint: TerrainBlueprint) -> Mesh:
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
					vertex_position.y = blueprint.get_height(height_sample_position + Vector2i(j, i))
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

	
