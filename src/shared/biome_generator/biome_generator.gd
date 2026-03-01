extends Node3D


@export_category("GeneratorNodes")
@export var wall_scene: String = "res://shared/biome_generator/wall/biome_wall.tscn"
@export_group("debug")
@export var point_scene: String = "res://shared/biome_generator/debug/generator_point_mesh.tscn"
@export var line_scene: String = "res://shared/biome_generator/debug/generator_line_mesh.tscn"
@export var triangle_scene: String = "res://shared/biome_generator/debug/generator_triangle_mesh.tscn"
@export_category("Biomes")
@export var biomes_sizes: Dictionary[String, int] = {
	"biom1": 13000,
	"biom2": 13000,
	"biom3": 13000
}
@export var biomes_colors: Dictionary[String, Color] = {
	"biom1": Color.BLUE, 
	"biom2": Color.RED,
	"biom3": Color.PURPLE
}
@export_category("GeneratorVariables")
@export var size_x: float = 200
@export var size_z: float = 200
@export var points_randomize_in_x: float = 0.99
@export var points_randomize_in_z: float = 0.99
@export var start_x: float = -100
@export var start_z: float = -100
@export var points_in_x: int = 50
@export var points_in_z: int = 50
@export var chance_to_shuffle: float = 0.01
@export var points_distance_from_border_not_randomized: int = 0
@export var additional_entrances: int = 5

var points: Dictionary[Vector2, Vector2]
var lines: Array[BiomeLine]
var vertical_lines: Array[BiomeLine]
var horizontal_lines: Array[BiomeLine]
var middle_lines: Array[BiomeLine]
var triangles: Array[BiomeTriangle]
var free_triangles: Array[BiomeTriangle]
var biomes: Array[Biome]
var walls_combiner: WallsCombiner

func _ready() -> void:
	generate()
	#show_debug()
	pass

func show_debug() -> void:
	get_tree().get_nodes_in_group("camera_debug_group").pop_front().queue_free()
	#_show_points()
	#_show_lines()
	#_show_biomes()





func generate() -> void:
	_set_points()
	_randomize_points()
	_set_lines_and_triangles()
	_set_biome()
	create_walls()
	_set_entrances()
	walls_combiner.use_collision = false
	walls_combiner.use_collision = true

func _set_points() -> void:
	for z: int in range(points_in_z):
		for x: int in range(points_in_x):
			points[Vector2(x, z)] = Vector2((x)*(size_x/(points_in_x-1)) + start_x, (z)*(size_z/(points_in_z-1))+start_z)

func _randomize_points() -> void:
	for z: int in range(points_distance_from_border_not_randomized, points_in_z-points_distance_from_border_not_randomized):
		for x: int in range(points_distance_from_border_not_randomized, points_in_x-points_distance_from_border_not_randomized):
			points[Vector2(x, z)].x += (size_x / (points_in_x-1)) * (randf() - 0.5) * points_randomize_in_x
			points[Vector2(x, z)].y += (size_z / (points_in_z-1)) * (randf() - 0.5) * points_randomize_in_z

func _set_lines_and_triangles() -> void:
	# Horizontal lines
	for z: int in range(points_in_z):
		for x: int in range(points_in_x-1):
			horizontal_lines.append(_create_line(points[Vector2(x, z)], points[Vector2(x+1, z)]))
	
	# Vertical lines
	for z: int in range(points_in_z-1):
		for x: int in range(points_in_x):
			vertical_lines.append(_create_line(points[Vector2(x, z)], points[Vector2(x, z+1)]))
	
	# Middle lines and triangles
	for z: int in range(points_in_z-1):
		for x: int in range(points_in_x-1):
			if randi()%2 == 1:
				middle_lines.append(_create_line(points[Vector2(x, z)], points[Vector2(x+1, z+1)]))
				triangles.append(_create_triangle(
					horizontal_lines[z*(points_in_x-1)+x], 
					vertical_lines[z*points_in_x+x+1], 
					middle_lines[-1]))
				triangles.append(_create_triangle(
					horizontal_lines[z*(points_in_x-1)+x+points_in_x-1], 
					vertical_lines[z*points_in_x+x], 
					middle_lines[-1]))
			else:
				middle_lines.append(_create_line(points[Vector2(x+1, z)], points[Vector2(x, z+1)]))
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
	var size_proportion: Dictionary[Biome, float]
	for biome_name in biomes_sizes:
		var biome: Biome = Biome.new()
		_init_biome(biome, biome_name)
		_get_biome_starting_triangle(biome)
		size_proportion[biome] = biome.area / biomes_sizes[biome_name]
	while free_triangles.size() > 0:
		var minimal: float = size_proportion.values().min()
		if minimal == INF:
			print("INF!!!!!!!!!!!!!!!!!!\n")
			break
		var biome: Biome = size_proportion.find_key(minimal)
		_get_biome_new_triangle(biome)
		size_proportion[biome] = biome.area / biomes_sizes[biome.biome_name]
	for biome in biomes:
		for line in biome.lines:
			line.biomes.append(biome)
		for triangle in biome.triangles:
			triangle.biome = biome
		if biome.area == INF:
			biome.area = 0
			for triangle in biome.triangles:
				biome.area += triangle.get_area()

func _init_biome(biome: Biome, biome_name: String) -> void:
	$Biomes.add_child(biome)
	biomes.append(biome)
	biome.name = biome_name
	biome.biome_name = biome_name
	biome.color = biomes_colors[biome_name]

func _get_biome_starting_triangle(biome: Biome) -> void:
	var triangle: BiomeTriangle = free_triangles.pick_random()
	_add_triangle_to_biome(biome, triangle)

func _get_biome_new_triangle(biome: Biome) -> void:
	var triangle: BiomeTriangle
	if randf() <= chance_to_shuffle:
		biome.lines.shuffle()
	var line_count: int = biome.lines.size()
	var i: int = 0
	while true:
		var line: BiomeLine = biome.lines.pop_front()
		biome.lines.push_back(line)
		if i == line_count:
			if biome.area >= biomes_sizes[biome.biome_name]:
				biome.area = INF
			else:
				_get_biome_starting_triangle(biome)
			return
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
			biome.lines.erase(line)
			return
		i += 1

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

func _set_entrances() -> void:
	var unchecked_triangles: Array[BiomeTriangle] = triangles.duplicate(false)
	var checked_triangles: Array[BiomeTriangle] = []
	var possible_passages: Array[BiomeLine] = []
	var blocked_passages: Array[BiomeLine] = []
	
	var starting_triangle: BiomeTriangle = unchecked_triangles.pop_front()
	checked_triangles.push_back(starting_triangle)
	possible_passages.push_back(starting_triangle.line_a)
	possible_passages.push_back(starting_triangle.line_b)
	possible_passages.push_back(starting_triangle.line_c)
	
	while not unchecked_triangles.is_empty():
		var passage: BiomeLine = possible_passages.pop_front()
		if passage == null:
			passage = blocked_passages.pick_random()
			_add_entrance_on_line(passage)
			blocked_passages.erase(passage)
			if unchecked_triangles.find(passage.adjacent_triangles[0]) >= 0:
				_check_triangle(passage.adjacent_triangles[0], unchecked_triangles, checked_triangles, possible_passages)
			elif unchecked_triangles.find(passage.adjacent_triangles[1]) >= 0:
				_check_triangle(passage.adjacent_triangles[1], unchecked_triangles, checked_triangles, possible_passages)
			continue
		elif passage.adjacent_triangles.size() >= 2:
			if unchecked_triangles.find(passage.adjacent_triangles[0]) >= 0:
				_check_passage(passage, passage.adjacent_triangles[1], passage.adjacent_triangles[0], unchecked_triangles, checked_triangles, possible_passages, blocked_passages)
			elif unchecked_triangles.find(passage.adjacent_triangles[1]) >= 0:
				_check_passage(passage, passage.adjacent_triangles[0], passage.adjacent_triangles[1], unchecked_triangles, checked_triangles, possible_passages, blocked_passages)
	for i in range(additional_entrances):
		if blocked_passages.is_empty():
			break
		var passage: BiomeLine = blocked_passages.pick_random()
		_add_entrance_on_line(passage)
		blocked_passages.erase(passage)

func _check_passage(passage: BiomeLine, 
		checked_triangle: BiomeTriangle, 
		unchecked_triangle: BiomeTriangle, 
		unchecked_triangles: Array[BiomeTriangle], 
		checked_triangles: Array[BiomeTriangle], 
		possible_passages: Array[BiomeLine], 
		blocked_passages: Array[BiomeLine]) -> void:
	pass
	if checked_triangle.biome == unchecked_triangle.biome:
		_check_triangle(unchecked_triangle, unchecked_triangles, checked_triangles, possible_passages)
	else:
		blocked_passages.append(passage)

func _check_triangle(triangle: BiomeTriangle, 
		unchecked_triangles: Array[BiomeTriangle], 
		checked_triangles: Array[BiomeTriangle], 
		possible_passages: Array[BiomeLine]) -> void:
	pass
	unchecked_triangles.erase(triangle)
	checked_triangles.push_back(triangle)
	possible_passages.push_front(triangle.line_a)
	possible_passages.push_front(triangle.line_b)
	possible_passages.push_front(triangle.line_c)

func _add_entrance_on_line(line: BiomeLine) -> void:
	var middle_point = (line.start_point + line.end_point)/2
	walls_combiner.add_entrance(Vector3(middle_point.x, 1, middle_point.y))


func create_walls() -> void:
	walls_combiner = WallsCombiner.new()
	self.add_child(walls_combiner)
	for line in lines:
		if not line.biomes.is_empty():
			var wall: BiomeWall = load(wall_scene).instantiate()
			walls_combiner.add_child(wall)
			wall.create_wall(line.start_point, line.end_point)
			for biome in line.biomes:
				wall.add_biome(biome)




func _show_points() -> void:
	for point: Vector2 in points:
		var mesh: MeshInstance3D = load(point_scene).instantiate()
		mesh.position.x = point.x
		mesh.position.z = point.y
		mesh.position.y = 0
		self.add_child(mesh)
		#print(point)

func _show_lines() -> void:
	for line: BiomeLine in lines:
		var mesh: MeshInstance3D = load(line_scene).instantiate()
		mesh.mesh.resource_local_to_scene = true
		mesh.mesh.size.x = line.get_length()
		mesh.rotation.y = line.get_rotation()
		mesh.position.x = line.start_point.x + ((line.end_point.x - line.start_point.x))/2
		mesh.position.z = line.start_point.y + ((line.end_point.y - line.start_point.y))/2
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
			mesh.position.x = 0
			mesh.position.z = 0
			self.add_child(mesh)
			
		for line: BiomeLine in biome.lines:
			var mesh: MeshInstance3D = load(line_scene).instantiate()
			mesh.mesh.resource_local_to_scene = true
			mesh.mesh.size.x = line.get_length()
			mesh.rotation.y = line.get_rotation()
			mesh.position.x = line.start_point.x + ((line.end_point.x - line.start_point.x))/2
			mesh.position.y += 0
			mesh.position.z = line.start_point.y + ((line.end_point.y - line.start_point.y))/2
			self.add_child(mesh)
