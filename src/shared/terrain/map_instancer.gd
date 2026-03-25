@tool
class_name MapInstancer
extends Resource

var SCENE_PATH: String =  ""

var world_generation_params: WorldGenerationParams
var world_display_params: WorldDisplayParams
var blueprint: MapTileData


func _init(manager: MapRenderer):
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params
	world_display_params = manager.world_display_params

func create_map_instance(manager: MapRenderer) -> void:
	var map_node := Node3D.new()
	var chunks_node := Node3D.new()
	
	for x in world_generation_params.map_size:
		for z in world_generation_params.map_size:
			create_chunk_instance(Vector2i(x,z), chunks_node)
			
	chunks_node.owner = map_node

func create_chunk_instance(
	chunk_coord: Vector2i, parent: Node3D
) -> Node3D:
	
	var chunk = Node3D.new()
	chunk.name = "ChunkX%dZ%d" % [chunk_coord.x, chunk_coord.y]

	# Godot requires to add node to tree before modifying it
	parent.add_child(chunk)

	chunk.global_position = Vector3(
		chunk_coord.x * world_generation_params.get_chunk_unit_size(),
		0,
		chunk_coord.y * world_generation_params.get_chunk_unit_size()
	)

	var chunk_mesh_instance = MeshInstance3D.new()
	chunk_mesh_instance.name = "ChunkMesh"

	chunk.add_child(chunk_mesh_instance)
	chunk_mesh_instance.owner = parent.get_tree().edited_scene_root

	chunk_mesh_instance.mesh = generate_chunk_mesh(chunk_coord)

	if world_display_params.terrain_material:
		chunk_mesh_instance.material_override = world_display_params.terrain_material

	chunk_mesh_instance.create_trimesh_collision()
	return chunk


func generate_chunk_mesh(chunk_coord: Vector2i) -> Mesh:
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
					vertex_position.y = blueprint.get_height(
						height_sample_position + Vector2i(j, i)
					)
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
	add_triangle(st, [vertices[0], vertices[1], vertices[3]])
	add_triangle(st, [vertices[0], vertices[3], vertices[2]])
