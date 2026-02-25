@tool
class_name ChunkGenerator
extends Node3D

@export_tool_button("Clean") var clean_action = clear_chunks

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

var active_chunks: Dictionary = {}

enum HeightMap {
	CURRENT,
	NEXT_X,
	NEXT_Z,
	NEXT_DIAG,
}

const quads = [
	# Main Tile
	[[0,HeightMap.CURRENT,0], [1,HeightMap.CURRENT,0], [1,HeightMap.CURRENT,1], [0,HeightMap.CURRENT,1]], 
	# Next Tile on X
	[[1,HeightMap.CURRENT,0], [2,HeightMap.NEXT_X,0], [2,HeightMap.NEXT_X,1], [1,HeightMap.CURRENT,1]],  
	# Next Tile on Z
	[[0,HeightMap.CURRENT,1], [1,HeightMap.CURRENT,1], [1,HeightMap.NEXT_Z,2], [0,HeightMap.NEXT_Z,2]],   
	# Next Tile Diagonally
	[[1,HeightMap.CURRENT,1], [2,HeightMap.NEXT_X,1], [2,HeightMap.NEXT_DIAG,2], [1,HeightMap.NEXT_Z,2]] 
]

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

	for x in range(0, chunk_size-1, 2):
		for z in range(0, chunk_size-1, 2):
			
			# Global coords for the 4 height samples
			var gx = (chunk_coord.x * chunk_size) + x
			var gz = (chunk_coord.y * chunk_size) + z
			
			# 4 heights from the blueprint
			var h0 = get_height_from_blueprint(gx, gz, blueprint)          # current
			var h1 = get_height_from_blueprint(gx + 2, gz, blueprint)      # next_x
			var h2 = get_height_from_blueprint(gx, gz + 2, blueprint)      # next_z
			var h3 = get_height_from_blueprint(gx + 2, gz + 2, blueprint)  # diag
			var heights = [h0, h1, h2, h3]
			
			# Tile position transformation
			var px = [x * tile_size, (x + 1) * tile_size, (x + 2) * tile_size]
			var pz = [z * tile_size, (z + 1) * tile_size, (z + 2) * tile_size]
			
			for q in quads:
				var v1 = Vector3(px[q[0][0]], heights[q[0][1]], pz[q[0][2]])
				var v2 = Vector3(px[q[1][0]], heights[q[1][1]], pz[q[1][2]])
				var v3 = Vector3(px[q[2][0]], heights[q[2][1]], pz[q[2][2]])
				var v4 = Vector3(px[q[3][0]], heights[q[3][1]], pz[q[3][2]])
				
				add_quad(st, v1, v2, v3, v4)

	# Finalize mesh
	st.generate_tangents()
	return st.commit()

func add_triangle(st: SurfaceTool, vertices: Array, nr: Vector3):
	for v in vertices:
		var uv = Vector2(v.x, v.z) / float(world_generation_params.tile_size)
		
		st.set_normal(nr)
		st.set_uv(uv)
		st.add_vertex(v)	

func add_quad(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
		
	# normals
	var nr1 = ((v3 - v1).cross(v2 - v1)).normalized()
	var nr2 = ((v4 - v1).cross(v3 - v1)).normalized()

	add_triangle(st, [v1,v2,v3], nr1)
	add_triangle(st, [v1,v3,v4], nr2)

func get_height_from_blueprint(gx: int, gz: int, blueprint: Dictionary) -> float:
	var coord = Vector2i(gx, gz)
	if blueprint.has(coord):
		return blueprint[coord].height
	elif blueprint.has(coord - Vector2i(0,1)):
		return blueprint[coord - Vector2i(0,1)].height
	elif blueprint.has(coord - Vector2i(1,0)):
		return blueprint[coord - Vector2i(1,0)].height
	elif blueprint.has(coord - Vector2i(1,1)):
		return blueprint[coord - Vector2i(1,1)].height
	return 0.0
	
