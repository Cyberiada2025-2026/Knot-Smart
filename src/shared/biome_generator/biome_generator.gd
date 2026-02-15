extends Node3D


@export_category("GeneratorNodes")
@export var wall_scene: String = "res://shared/biome_generator/wall.tscn"
@export_group("debug")
@export var point_scene: String = "res://shared/biome_generator/debug/generator_point_mesh.tscn"
@export var line_scene: String = "res://shared/biome_generator/debug/generator_line_mesh.tscn"
@export var triangle_scene: String = "res://shared/biome_generator/debug/generator_triangle_mesh.tscn"
@export_category("Biomes")
@export var biomes_sizes: Dictionary[String, int] = {
	"start": 5000,
	"sklepowy": 5000,
	"inny": 5000
}
@export var biomes_colors: Dictionary[String, Color] = {
	"start": Color.BLUE, 
	"sklepowy": Color.RED,
	"inny": Color.PURPLE
}
@export_category("GeneratorVariables")
@export var size_x: float = 200
@export var size_z: float = 200
@export var points_randomize_in_x: float = 4.5
@export var points_randomize_in_z: float = 4.5
@export var start_x: float = 100
@export var start_z: float = 100
@export var points_in_x: int = 21
@export var points_in_z: int = 21

var points: Array[Vector2]
var lines: Array[BiomeLine]
var vertical_lines: Array[BiomeLine]
var horizontal_lines: Array[BiomeLine]
var middle_lines: Array[BiomeLine]
var triangles: Array[BiomeTriangle]
var free_triangles: Array[BiomeTriangle]
var biomes: Array[Biome]

func _ready() -> void:
	generate()
	show_debug()
	create_walls()




func generate() -> void:
	_set_points()
	_randomize_points()
	_set_lines_and_triangles()
	_set_biome()
	_show_biomes()

func _set_points() -> void:
	for z: int in range(points_in_x):
		for x: int in range(points_in_z):
			points.append(Vector2((x)*(size_x/(points_in_x-1)), (z)*(size_z/(points_in_z-1))))

func _randomize_points() -> void:
	for z: int in range(1, points_in_x-1):
		for x: int in range(1, points_in_z-1):
			var i:int = z*points_in_x+x
			#print(i%s, "  ", i/s, "  ", points[i])
			points[i].x += (2*randf()-1) * points_randomize_in_x
			points[i].y += (2*randf()-1) * points_randomize_in_z

func _set_lines_and_triangles() -> void:
	# Horizontal lines
	for z: int in range(points_in_x):
		for x: int in range(points_in_z-1):
			var i:int = z*(points_in_x)+x
			horizontal_lines.append(_create_line(points[i], points[i+1]))
	
	# Vertical lines
	for z: int in range(points_in_x-1):
		for x: int in range(points_in_z):
			var i:int = z*(points_in_x)+x
			vertical_lines.append(_create_line(points[i], points[i+points_in_x]))
	
	# Middle lines and triangles
	for z: int in range(points_in_x-1):
		for x: int in range(points_in_z-1):
			var i:int = z*points_in_x+x
			if randi()%2 == 1:
				middle_lines.append(_create_line(points[i], points[i+points_in_x+1]))
				triangles.append(_create_triangle(
					horizontal_lines[z*(points_in_x-1)+x], 
					vertical_lines[z*points_in_x+x+1], 
					middle_lines[-1]))
				triangles.append(_create_triangle(
					horizontal_lines[z*(points_in_x-1)+x+points_in_x-1], 
					vertical_lines[z*points_in_x+x], 
					middle_lines[-1]))
			else:
				middle_lines.append(_create_line(points[i+1], points[i+points_in_x]))
				triangles.append(_create_triangle(
					horizontal_lines[z*(points_in_x-1)+x], 
					vertical_lines[z*points_in_x+x], 
					middle_lines[-1]))
				triangles.append(_create_triangle(
					horizontal_lines[z*(points_in_x-1)+x+points_in_x-1], 
					vertical_lines[z*points_in_x+x+1], 
					middle_lines[-1]))
	
	lines.append_array(horizontal_lines)
	lines.append_array(vertical_lines)
	lines.append_array(middle_lines)

func _create_line(start: Vector2, end: Vector2) -> BiomeLine:
	var line: BiomeLine = BiomeLine.new()
	line.start_point = start
	line.end_point = end
	return line

func _create_triangle(line_a: BiomeLine, line_b: BiomeLine, line_c: BiomeLine) -> BiomeTriangle:
	var triangle: BiomeTriangle = BiomeTriangle.new()
	triangle.line_a = line_a
	triangle.line_b = line_b
	triangle.line_c = line_c
	line_a.adjacent_triangles.append(triangle)
	line_b.adjacent_triangles.append(triangle)
	line_c.adjacent_triangles.append(triangle)
	return triangle

func _set_biome() -> void:
	free_triangles = triangles.duplicate(false)
	for biome_name in biomes_sizes:
		var biome: Biome = Biome.new()
		_init_biome(biome, biome_name)
		_get_biome_starting_triangle(biome)
		while biome.area < biomes_sizes[biome_name]:
			_get_biome_new_triangle(biome)
		for line in biome.lines:
			line.biomes.append(biome)
		for triangle in biome.triangles:
			triangle.biomes.append(biome)

func _init_biome(biome: Biome, biome_name: String) -> void:
	biome.name = biome_name
	biome.color = biomes_colors[biome_name]
	$Biomes.add_child(biome)
	biomes.append(biome)

func _get_biome_starting_triangle(biome: Biome) -> void:
	var triangle: BiomeTriangle = free_triangles.pick_random()
	_add_triangle_to_biome(biome, triangle)

func _get_biome_new_triangle(biome: Biome) -> void:
	var triangle: BiomeTriangle
	var start_line_id: int = randi()%biome.lines.size()
	var line_id: int = start_line_id
	while line_id+1 != start_line_id:
		var line: BiomeLine = biome.lines[line_id]
		var r: int = randi()%line.adjacent_triangles.size()
		var traingle1 = line.adjacent_triangles[r]
		var traingle2 = line.adjacent_triangles[(r+1)%line.adjacent_triangles.size()]
		if free_triangles.find(traingle1) >= 0:
			triangle = traingle1
			biome.lines.erase(line)
			_add_triangle_to_biome(biome, triangle)
			biome.lines.erase(line)
			return
		elif free_triangles.find(traingle2) >= 0:
			triangle = traingle2
			biome.lines.erase(line)
			_add_triangle_to_biome(biome, triangle)
			return
		line_id = (line_id+1)%biome.lines.size()
	print("no triangle")
	_get_biome_starting_triangle(biome)

func _add_triangle_to_biome(biome: Biome, triangle: BiomeTriangle) -> void:
	free_triangles.erase(triangle)
	biome.triangles.append(triangle)
	_add_line_to_biome(biome, triangle.line_a)
	_add_line_to_biome(biome, triangle.line_b)
	_add_line_to_biome(biome, triangle.line_c)
	biome.area += triangle.get_area()

func _add_line_to_biome(biome: Biome, line: BiomeLine) -> void:
	if line.adjacent_triangles.size() == 1:
		biome.lines.append(line)
		return
	if biome.triangles.find(line.adjacent_triangles[0]) == -1:
		biome.lines.append(line)
		return
	else:
		biome.lines.erase(line)
	if biome.triangles.find(line.adjacent_triangles[1]) == -1:
		biome.lines.append(line)
		return
	else:
		biome.lines.erase(line)




func show_debug() -> void:
	_show_points()
	_show_lines()
	_set_biome()

func _show_points() -> void:
	for point: Vector2 in points:
		var mesh: MeshInstance3D = load(point_scene).instantiate()
		mesh.position.x = point.x - start_x
		mesh.position.z = point.y - start_x
		mesh.position.y = 0
		self.add_child(mesh)
		#print(point)

func _show_lines() -> void:
	for line: BiomeLine in lines:
		var mesh: MeshInstance3D = load(line_scene).instantiate()
		mesh.mesh.resource_local_to_scene = true
		mesh.mesh.size.x = line.get_length()
		mesh.rotation.y = line.get_rotation()
		mesh.position.x = line.start_point.x - start_x + ((line.end_point.x - line.start_point.x))/2
		mesh.position.z = line.start_point.y - start_z + ((line.end_point.y - line.start_point.y))/2
		self.add_child(mesh)

func _show_biomes() -> void:
	for biome in biomes:
		for triangle in biome.triangles:
			#print("dsfadfa")
			var point1: Vector2 = triangle.line_a.start_point
			var point2: Vector2 = triangle.line_a.end_point
			var point3: Vector2
			if triangle.line_b.start_point != point1 and triangle.line_b.start_point != point2:
				point3 = triangle.line_b.start_point
			else:
				point3 = triangle.line_b.end_point
			var mesh: CSGPolygon3D = load(triangle_scene).instantiate()
			mesh.polygon = PackedVector2Array([point1, point2, point3])
			mesh.material.albedo_color = biome.color
			mesh.material.resource_local_to_scene = true
			mesh.position.x = -start_x
			mesh.position.z = -start_z
			self.add_child(mesh)
			
		for line: BiomeLine in biome.lines:
			var mesh: MeshInstance3D = load(line_scene).instantiate()
			mesh.mesh.resource_local_to_scene = true
			mesh.mesh.size.x = line.get_length()
			mesh.rotation.y = line.get_rotation()
			mesh.position.x = line.start_point.x - start_x + ((line.end_point.x - line.start_point.x))/2
			mesh.position.z = line.start_point.y - start_z + ((line.end_point.y - line.start_point.y))/2
			self.add_child(mesh)




func create_walls() -> void:
	for line in lines:
		if not line.biomes.is_empty():
			var wall: BiomeWall = BiomeWall.new()
			wall.create_wall(line.start_point, line.end_point)
			for biome in line.biomes:
				wall.add_biome(biome)
