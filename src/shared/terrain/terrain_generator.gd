@tool
class_name TerrainGenerator
extends Node

var world_generation_params: WorldGenerationParams
var blueprint: MapTileData

func run_generation(manager: GridGenerationPipeline) -> void:
	blueprint = manager.blueprint
	world_generation_params = manager.world_generation_params

	for x in blueprint.world_size:
		for z in blueprint.world_size:
			var coord = Vector2i(x, z)

			var raw_val = world_generation_params.noise.get_noise_2d(x, z)
			var normalized = (raw_val + 1) / 2.0
			var level = floor(
				(
					(normalized + world_generation_params.height_displacement)
					* world_generation_params.map_height
				)
			)

			var final_height = level * world_generation_params.tile_height

			blueprint.data[coord].height = final_height

	for x in blueprint.world_size:
		for z in blueprint.world_size:
			var coord = Vector2i(x, z)

			var mi = MeshInstance3D.new()
			mi.mesh = generate_tile_mesh(coord)
			mi.position = Vector3(
				x * world_generation_params.tile_size, 0, z * world_generation_params.tile_size
			)

			var tile = blueprint.data[coord]
			tile.height = blueprint.get_height(coord)
			tile.objects.clear()
			tile.objects.append(mi)


func generate_tile_mesh(coord: Vector2i) -> Mesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var x = coord.x
	var z = coord.y
	var ts = world_generation_params.tile_size

	var h0 = blueprint.get_height(Vector2i(x, z))  # Current (Top-Left)
	var h1 = blueprint.get_height(Vector2i(x + 1, z))  # Neighbor X (Top-Right)
	var h2 = blueprint.get_height(Vector2i(x, z + 1))  # Neighbor Z (Bottom-Left)
	var h3 = blueprint.get_height(Vector2i(x + 1, z + 1))  # Neighbor Diag (Bottom-Right)

	var v0 = Vector3(0, h0, 0)
	var v1 = Vector3(ts, h1, 0)
	var v2 = Vector3(0, h2, ts)
	var v3 = Vector3(ts, h3, ts)

	add_triangle(st, [v0, v1, v2])
	add_triangle(st, [v1, v3, v2])

	st.generate_tangents()
	return st.commit()


func add_triangle(st: SurfaceTool, vertices: Array):
	var normal = ((vertices[2] - vertices[0]).cross(vertices[1] - vertices[0])).normalized()
	for v in vertices:
		var uv = Vector2(v.x, v.z) / float(world_generation_params.tile_size)

		st.set_normal(normal)
		st.set_uv(uv)
		st.add_vertex(v)
