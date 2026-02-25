@tool
class_name ChunkGenerator
extends Node3D

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var active_chunks: Dictionary = {}

const quads = [
	[[0,0,0], [1,0,0], [1,1,0], [0,1,0]], # Flat top-left
	[[1,0,0], [2,0,1], [2,1,1], [1,1,0]], # Slope X
	[[0,1,0], [1,1,0], [1,2,2], [0,2,2]], # Slope Z
	[[1,1,0], [2,1,1], [2,2,3], [1,2,2]]  # Corner Diag
]

func clear_chunks(render_position = null) -> void:
	
	#var chunk_offset = world_generation_params.chunk_size * world_generation_params.tile_size
	
	if render_position == null:
		for child in get_children():
			if child is MeshInstance3D:
				child.free()
		active_chunks.clear()
		return

	#var center_coord = Vector2i(
		#floor(render_position.x / chunk_offset),
		#floor(render_position.y / chunk_offset)
	#)
	#
	#for coord in active_chunks.keys():
		#var diff = (coord - center_coord).abs()
		#if diff.x > world_display_params.render_distance or diff.y > world_display_params.render_distance:
			#if is_instance_valid(active_chunks[coord]):
				#active_chunks[coord].queue_free()
				#remove_child(active_chunks[coord])
			#active_chunks.erase(coord)
		

func generate_chunks(blueprint, render_position) -> void:
	clear_chunks()
	
	for x in world_generation_params.map_size:
		for z in world_generation_params.map_size:
			var coord = Vector2i(x, z)
			_create_chunk_node(coord, blueprint)
			
	print("ChunkGenerator: Active chunks: ", active_chunks.size())

func _create_chunk_node(c_coord: Vector2i, blueprint: Dictionary) -> void:
	var chunk = MeshInstance3D.new()
	
	chunk.name = "Chunk_%d_%d" % [c_coord.x, c_coord.y]
	add_child(chunk)
	chunk.owner = get_tree().edited_scene_root
	
	var chunk_offset = world_generation_params.chunk_size * world_generation_params.tile_size
	chunk.global_position = Vector3(c_coord.x * chunk_offset, 0, c_coord.y * chunk_offset)
	
	var mesh = generate_chunk_mesh(c_coord, blueprint)
	chunk.mesh = mesh
	
	chunk.create_trimesh_collision()
	
	if world_display_params.terrain_material:
		chunk.material_override = world_display_params.terrain_material
		
	active_chunks[c_coord] = chunk

func generate_chunk_mesh(c_coord: Vector2i, blueprint: Dictionary) -> Mesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var c_size = world_generation_params.chunk_size
	var t_size = world_generation_params.tile_size

	for x in range(0, c_size, 2):
		for z in range(0, c_size, 2):
			
			# Global coords for the 4 height samples
			var gx = (c_coord.x * c_size) + x
			var gz = (c_coord.y * c_size) + z
			
			# 4 heights from the blueprint
			var h0 = get_height_from_blueprint(gx, gz, blueprint)          # current
			var h1 = get_height_from_blueprint(gx + 2, gz, blueprint)      # next_x
			var h2 = get_height_from_blueprint(gx, gz + 2, blueprint)      # next_z
			var h3 = get_height_from_blueprint(gx + 2, gz + 2, blueprint)  # diag
			var heights = [h0, h1, h2, h3]
			
			# px[0]=start, px[1]=middle, px[2]=end
			var px = [x * t_size, (x + 1) * t_size, (x + 2) * t_size]
			var pz = [z * t_size, (z + 1) * t_size, (z + 2) * t_size]
			
			for q in quads:
				var v1 = Vector3(px[q[0][0]], heights[q[0][2]], pz[q[0][1]])
				var v2 = Vector3(px[q[1][0]], heights[q[1][2]], pz[q[1][1]])
				var v3 = Vector3(px[q[2][0]], heights[q[2][2]], pz[q[2][1]])
				var v4 = Vector3(px[q[3][0]], heights[q[3][2]], pz[q[3][1]])
				
				add_quad_with_uv(st, v1, v2, v3, v4)

	# Finalize mesh
	#st.generate_normals() #write own version
	st.generate_tangents()
	return st.commit()

func add_quad_with_uv(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
	# UV na podstawie pozycji + tile'ow
	var uv1 = Vector2(v1.x, v1.z) / float(world_generation_params.tile_size)
	var uv2 = Vector2(v2.x, v2.z) / float(world_generation_params.tile_size)
	var uv3 = Vector2(v3.x, v3.z) / float(world_generation_params.tile_size)
	var uv4 = Vector2(v4.x, v4.z) / float(world_generation_params.tile_size)
	
	# normals
	var nr1 = ((v3 - v1).cross(v2-v1)).normalized()
	var nr2 = ((v4 - v1).cross(v3-v1)).normalized()

	st.set_normal(nr1)
	st.set_uv(uv1)
	
	st.add_vertex(v1)
	
	st.set_normal(nr1)
	st.set_uv(uv2)
	
	st.add_vertex(v2)
	
	st.set_normal(nr1)
	st.set_uv(uv3)
	
	st.add_vertex(v3)
	#second triangle
	st.set_normal(nr2)
	st.set_uv(uv1)
	
	st.add_vertex(v1)
	
	st.set_normal(nr2)
	st.set_uv(uv3)
	
	st.add_vertex(v3)
	
	st.set_normal(nr2)
	st.set_uv(uv4)
	
	st.add_vertex(v4)

func get_height_from_blueprint(gx: int, gz: int, blueprint: Dictionary) -> float:
	var coord = Vector2i(gx, gz)
	if blueprint.has(coord):
		return blueprint[coord].height
	return 0.0
	
