@tool
class_name ChunkGenerator
extends Resource

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams

func _init(gen_params: WorldGenerationParams, disp_params: WorldDisplayParams):
	world_generation_params = gen_params
	world_display_params = disp_params

func create_chunk_instance(chunk_coord: Vector2i, blueprint: TerrainBlueprint) -> MeshInstance3D:
	var chunk = MeshInstance3D.new()
	chunk.name = "ChunkX%dZ%d" % [chunk_coord.x, chunk_coord.y]

	var chunk_unit_size = world_generation_params.chunk_size * world_generation_params.tile_size
	chunk.global_position = Vector3(chunk_coord.x * chunk_unit_size, 0, chunk_coord.y * chunk_unit_size)
	
	chunk.mesh = generate_chunk_mesh(chunk_coord, blueprint)
		
	if world_display_params.terrain_material:
		chunk.material_override = world_display_params.terrain_material
			
	chunk.create_trimesh_collision()
	return chunk
	
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

	
