@tool
class_name TerrainGenerator
extends MeshInstance3D

@export var terrain_generation_params: TerrainGenerationParams
@export_tool_button("Generate Terrain") var generate_terrain_action = generate_terrain
@export_tool_button("Generate Structures") var generate_structures_action = generate_structures
@export_tool_button("Clear Terrain") var clear_terrain_action = clear_terrain
@export_tool_button("Clear Structures") var clear_structures_action = clear_structures

var quads = [
	
[[0,0,0], [1,0,0], [1,1,0], [0,1,0]], # Flat top-left
[[1,0,0], [2,0,1], [2,1,1], [1,1,0]], # Slope X
[[0,1,0], [1,1,0], [1,2,2], [0,2,2]], # Slope Z
[[1,1,0], [2,1,1], [2,2,3], [1,2,2]]  # Corner Diag

]

var valid_flat_spots: Array[Vector3] = []

func clear_terrain() -> void:
	valid_flat_spots = []
	self.mesh = null
	
# temporary solution
func clear_structures() -> void:
	for child in get_children():
			if child.has_method("update_structures"):
					child.multimesh = null
					
# temporary solution
func generate_structures() -> void:
		for child in get_children():
			if child.has_method("update_structures"):
				child.update_structures(valid_flat_spots)
	

func generate_terrain():
	clear_terrain()
	if is_inside_tree(): return update_mesh()

func get_height(x: float, y: float) -> float:
	var h := 0.0
	if terrain_generation_params.noise:
		h = terrain_generation_params.noise.get_noise_2d(x, y)
	if h <= 0: return 0.0
	return snapped(floor(h*terrain_generation_params.map_height), terrain_generation_params.tile_height)

# funkcja na quady
func add_quad_with_uv(st: SurfaceTool, v1: Vector3, v2: Vector3, v3: Vector3, v4: Vector3):
	# UV na podstawie pozycji + tile'ow
	var uv1 = Vector2(v1.x, v1.z) / float(terrain_generation_params.tile_size)
	var uv2 = Vector2(v2.x, v2.z) / float(terrain_generation_params.tile_size)
	var uv3 = Vector2(v3.x, v3.z) / float(terrain_generation_params.tile_size)
	var uv4 = Vector2(v4.x, v4.z) / float(terrain_generation_params.tile_size)

	st.set_uv(uv1); st.add_vertex(v1)
	st.set_uv(uv2); st.add_vertex(v2)
	st.set_uv(uv3); st.add_vertex(v3)
	
	st.set_uv(uv1); st.add_vertex(v1)
	st.set_uv(uv3); st.add_vertex(v3)
	st.set_uv(uv4); st.add_vertex(v4)

func update_mesh() -> Array:
	if not is_inside_tree(): return valid_flat_spots
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for x in range(0, terrain_generation_params.map_size, 2):
		for z in range(0, terrain_generation_params.map_size, 2):
			
			var h_current = get_height(x, z)
			var h_next_x  = get_height(x + 2, z)
			var h_next_z  = get_height(x, z + 2)
			var h_diag    = get_height(x + 2, z + 2)
			var heights = [h_current, h_next_x, h_next_z, h_diag]
			
			var px = [x * terrain_generation_params.tile_size, (x + 1) * terrain_generation_params.tile_size, (x + 2) * terrain_generation_params.tile_size]
			var pz = [z * terrain_generation_params.tile_size, (z + 1) * terrain_generation_params.tile_size, (z + 2) * terrain_generation_params.tile_size]
			
			for q in quads:
				add_quad_with_uv(st,
					Vector3(px[q[0][0]], heights[q[0][2]], pz[q[0][1]]),
					Vector3(px[q[1][0]], heights[q[1][2]], pz[q[1][1]]),
					Vector3(px[q[2][0]], heights[q[2][2]], pz[q[2][1]]),
					Vector3(px[q[3][0]], heights[q[3][2]], pz[q[3][1]])
				)
			valid_flat_spots.append(Vector3((x + 0.5) * terrain_generation_params.tile_size, h_current, (z + 0.5) * terrain_generation_params.tile_size))
	st.index() # usuniecie tego daje wyglad bardziej low poly
	st.generate_normals()
	st.generate_tangents()
	
	mesh = st.commit()
	
	# temporary solution
	for child in get_children():
		if child.has_method("update_structures"):
			child.update_structures(valid_flat_spots)
	return valid_flat_spots
