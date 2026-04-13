@tool
#class_name BiomeGenerator
extends Node3D

@export_category("GeneratorNodes")
@export var wall_scene: PackedScene = preload("res://shared/biome_generator/wall/biome_wall.tscn")
@export_group("debug")
@export var point_scene: PackedScene = preload(
	"res://shared/biome_generator/debug/generator_point_mesh.tscn"
)
@export
var line_scene: PackedScene = preload("res://shared/biome_generator/debug/generator_line_mesh.tscn")
@export var triangle_scene: PackedScene = preload(
	"res://shared/biome_generator/debug/generator_triangle_mesh.tscn"
)

@export_category("Biomes")
## Minimal area of biomes in m^2
@export var biomes_areas: Dictionary[String, int] = {
	"biome1": 10000,
	"biome2": 10000,
	"biome3": 10000
}

@export_category("GeneratorVariables")
@export var custom_seed: String = ""
@export_group("location")
@export var size: Vector2 = Vector2(200, 200)
@export var start: Vector2 = Vector2(-100, -100)
@export_group("points")
## number of points in x/z
@export var points_in: Vector2 = Vector2(50, 50)
## number of points from border that will not be affected by randomization
@export var randomization_margin: int = 0
## percentage of half averange distance
@export var randomization_strength: Vector2 = Vector2(0.99, 0.99)
@export_group("triangles selection")
## chance to shuffle possible triangles, during every selection of next biome triangle
@export var chance_to_shuffle: float = 0.01
@export_group("Entrances")
## number of entrances that will generate besides minimal ones
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
var rng: RandomNumberGeneratorUpgraded

func _ready() -> void:
	_set_rng()

func show_debug() -> void:
	_show_biomes()

func reset() -> void:
	points = {}
	lines = []
	vertical_lines = []
	horizontal_lines = []
	middle_lines = []
	triangles = []
	free_triangles = []
	biomes = []
	if get_child(0) != null:
		get_child(0).queue_free()
	_set_rng()

func _set_rng():
	rng = RandomNumberGeneratorUpgraded.new()
	if custom_seed == "":
		rng.randomize()
	else:
		rng.seed = custom_seed.hash()

func generate() -> void:
	_create_point_grid()
	_randomize_points()
	_set_lines_and_triangles()
	_set_biome()
	create_walls()
	_set_passages()
	walls_combiner.force_update_transform()
	walls_combiner.use_collision = false
	walls_combiner.use_collision = true

func _get_step_size_x() -> float:
	return (size.x / (points_in.x - 1))

func _get_step_size_z() -> float:
	return (size.y / (points_in.y - 1))

func _create_point_grid() -> void:
	for z: int in range(points_in.y):
		for x: int in range(points_in.x):
			points[Vector2(x, z)] = Vector2(
				(x) * _get_step_size_x() + start.x,
				(z) * _get_step_size_z() + start.y
			)


func _randomize_points() -> void:
	for z: int in range(
		randomization_margin,
		points_in.y - randomization_margin
	):
		for x: int in range(
			randomization_margin,
			points_in.x - randomization_margin
		):
			points[Vector2(x, z)].x += (
				_get_step_size_x() * (rng.randf() - 0.5) * randomization_strength.x
			)
			points[Vector2(x, z)].y += (
				_get_step_size_z() * (rng.randf() - 0.5) * randomization_strength.y
			)


func _set_lines_and_triangles() -> void:
	# Horizontal lines
	for z: int in range(points_in.y):
		for x: int in range(points_in.x - 1):
			horizontal_lines.append(_create_line(points[Vector2(x, z)], points[Vector2(x + 1, z)]))
	# Vertical lines
	for z: int in range(points_in.y - 1):
		for x: int in range(points_in.x):
			vertical_lines.append(_create_line(points[Vector2(x, z)], points[Vector2(x, z + 1)]))
	# Middle lines and triangles
	for z: int in range(points_in.y - 1):
		for x: int in range(points_in.x - 1):
			_create_triangles_from_lines(x, z, rng.randi()%2)
	lines.append_array(horizontal_lines)
	lines.append_array(vertical_lines)
	lines.append_array(middle_lines)

func _create_triangles_from_lines(x: int, z: int, chosen_middle_line: int) -> void:
	middle_lines.append(
		_create_line(
			points[Vector2(x+(1-chosen_middle_line), z)],
			points[Vector2(x+chosen_middle_line, z+1)]
		)
	)
	_create_upper_triangle_from_lines(x, z, chosen_middle_line)
	_create_lower_triangle_from_lines(x, z, chosen_middle_line)

func _create_upper_triangle_from_lines(x: int, z: int, chosen_middle_line: int) -> void:
	triangles.append(
		_create_triangle(
			horizontal_lines[z * (points_in.x - 1) + x],
			vertical_lines[z * points_in.x + x + chosen_middle_line],
			middle_lines[-1]
		)
	)

func _create_lower_triangle_from_lines(x: int, z: int, chosen_middle_line: int) -> void:
	triangles.append(
		_create_triangle(
			horizontal_lines[z * (points_in.x - 1) + x + points_in.x - 1],
			vertical_lines[z * points_in.x + x + (1-chosen_middle_line)],
			middle_lines[-1]
		)
	)

func _create_line(line_start: Vector2, line_end: Vector2) -> BiomeLine:
	var line: BiomeLine = BiomeLine.new()
	line.start_point = line_start
	line.end_point = line_end
	return line


func _create_triangle(line_a: BiomeLine, line_b: BiomeLine, line_c: BiomeLine) -> BiomeTriangle:
	var triangle: BiomeTriangle = BiomeTriangle.new()
	for line in [line_a, line_b, line_c]:
		triangle.lines.append(line)
		line.adjacent_triangles.append(triangle)
	return triangle
























func _set_biome() -> void:
	free_triangles = triangles.duplicate(false)
	var size_proportion: Dictionary[Biome, float]
	_create_biom(size_proportion)
	_asign_free_triangles(size_proportion)
	_finalize_biomes()

func _create_biom(size_proportion: Dictionary[Biome, float]) -> void:
	for biome_name in biomes_areas:
		var biome: Biome = Biome.new()
		_init_biome(biome, biome_name)
		_get_biome_starting_triangle(biome)
		size_proportion[biome] = biome.area / biomes_areas[biome_name]

func _asign_free_triangles(size_proportion: Dictionary[Biome, float]) -> void:
	while free_triangles.size() > 0:
		var minimal: float = size_proportion.values().min()
		var biome: Biome = size_proportion.find_key(minimal)
		_get_biome_new_triangle(biome)
		size_proportion[biome] = biome.area / biomes_areas[biome.biome_name]

func _finalize_biomes() -> void:
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
	self.add_child(biome)
	biomes.append(biome)
	biome.name = biome_name
	biome.biome_name = biome_name


func _get_biome_starting_triangle(biome: Biome) -> void:
	var triangle: BiomeTriangle = rng.pick_random(free_triangles)
	_add_triangle_to_biome(biome, triangle)


func _get_biome_new_triangle(biome: Biome) -> void:
	if rng.randf() <= chance_to_shuffle:
		rng.shuffle(biome.lines)
	var line_count: int = biome.lines.size()
	for i in range(line_count):
		var line: BiomeLine = biome.lines.pop_front()
		biome.lines.push_back(line)
		for triangle in line.adjacent_triangles:
			if free_triangles.find(triangle) >= 0:
				biome.lines.erase(line)
				_add_triangle_to_biome(biome, triangle)
				biome.lines.erase(line)
				return
	if biome.area >= biomes_areas[biome.biome_name]:
		biome.area = INF
	else:
		_get_biome_starting_triangle(biome)


func _add_triangle_to_biome(biome: Biome, triangle: BiomeTriangle) -> void:
	free_triangles.erase(triangle)
	biome.triangles.append(triangle)
	for line in triangle.lines:
		_add_line_to_biome(biome, line)
	biome.area += triangle.get_area()


func _add_line_to_biome(biome: Biome, line: BiomeLine) -> void:
	if line.adjacent_triangles.size() == 1:
		biome.lines.append(line)
		return
	for triangle in line.adjacent_triangles:
		if biome.triangles.find(triangle) == -1:
			biome.lines.append(line)
			return
		biome.lines.erase(line)
































func _set_passages() -> void:
	var unchecked_triangles: Array[BiomeTriangle] = triangles.duplicate(false)
	var checked_triangles: Array[BiomeTriangle] = []
	var possible_passages: Array[BiomeLine] = []
	var blocked_passages: Array[BiomeLine] = []
	var starting_triangle: BiomeTriangle = unchecked_triangles.pop_front()
	checked_triangles.push_back(starting_triangle)
	possible_passages.append_array(starting_triangle.lines)
	while not unchecked_triangles.is_empty():
		var passage: BiomeLine = possible_passages.pop_front()
		if passage == null:
			_open_blocked_passage(
				unchecked_triangles,
				checked_triangles,
				possible_passages,
				blocked_passages
			)
			continue
		elif passage.adjacent_triangles.size() >= 2:
			_check_passage(
				passage,
				unchecked_triangles,
				checked_triangles,
				possible_passages,
				blocked_passages
			)
	for i in range(additional_entrances):
		if blocked_passages.is_empty():
			break
		var passage: BiomeLine = rng.pick_random(blocked_passages)
		_add_entrance_on_line(passage)
		blocked_passages.erase(passage)

func _open_blocked_passage(
	unchecked_triangles: Array[BiomeTriangle],
	checked_triangles: Array[BiomeTriangle],
	possible_passages: Array[BiomeLine],
	blocked_passages: Array[BiomeLine]
) -> BiomeLine:
	var passage: BiomeLine
	passage = rng.pick_random(blocked_passages)
	_add_entrance_on_line(passage)
	blocked_passages.erase(passage)
	for adjacent_triangle in passage.adjacent_triangles:
		if unchecked_triangles.find(adjacent_triangle) >= 0:
			_check_triangle(
				adjacent_triangle,
				unchecked_triangles,
				checked_triangles,
				possible_passages
			)
	return passage

func _check_passage(
	passage: BiomeLine,
	unchecked_triangles: Array[BiomeTriangle],
	checked_triangles: Array[BiomeTriangle],
	possible_passages: Array[BiomeLine],
	blocked_passages: Array[BiomeLine]
) -> void:
	for adjacent_triangle in passage.adjacent_triangles:
		if unchecked_triangles.find(adjacent_triangle) >= 0:
			var checked_triangle: BiomeTriangle = passage.adjacent_triangles.get(
				(passage.adjacent_triangles.find(adjacent_triangle)+1)%
				passage.adjacent_triangles.size()
			)
			if checked_triangle.biome == adjacent_triangle.biome:
				_check_triangle(
					adjacent_triangle, unchecked_triangles, checked_triangles, possible_passages
				)
			else:
				blocked_passages.append(passage)


func _check_triangle(
	triangle: BiomeTriangle,
	unchecked_triangles: Array[BiomeTriangle],
	checked_triangles: Array[BiomeTriangle],
	possible_passages: Array[BiomeLine]
) -> void:
	unchecked_triangles.erase(triangle)
	checked_triangles.push_back(triangle)
	possible_passages.append_array(triangle.lines)


func _add_entrance_on_line(line: BiomeLine) -> void:
	var middle_point = (line.start_point + line.end_point) / 2
	walls_combiner.add_entrance(Vector3(middle_point.x, 1, middle_point.y))


func create_walls() -> void:
	walls_combiner = WallsCombiner.new()
	self.add_child(walls_combiner)
	walls_combiner.owner = self
	for line in lines:
		if not line.biomes.is_empty():
			var wall: BiomeWall = wall_scene.instantiate()
			walls_combiner.add_child(wall)
			wall.owner = self
			wall.create_wall(line.start_point, line.end_point)
			for biome in line.biomes:
				wall.add_biome(biome)


func _show_points() -> void:
	for point: Vector2 in points:
		var mesh: MeshInstance3D = point_scene.instantiate()
		mesh.position.x = point.x
		mesh.position.z = point.y
		mesh.position.y = 0
		self.add_child(mesh)


func _show_lines() -> void:
	for line: BiomeLine in lines:
		var mesh: MeshInstance3D = line_scene.instantiate()
		mesh.mesh.resource_local_to_scene = true
		mesh.mesh.size.x = line.get_length()
		mesh.rotation.y = line.get_rotation()
		mesh.position.x = line.get_middle().x
		mesh.position.z = line.get_middle().y
		self.add_child(mesh)


func _show_biomes() -> void:
	for biome in biomes:
		for triangle in biome.triangles:
			_show_biome_triangle(triangle)
		for line: BiomeLine in biome.lines:
			_show_biome_line(line)

func _show_biome_triangle(triangle: BiomeTriangle) -> void:
	var point1: Vector2 = triangle.lines[0].start_point
	var point2: Vector2 = triangle.lines[0].end_point
	var point3: Vector2
	if triangle.lines[1].start_point != point1 and triangle.lines[1].start_point != point2:
		point3 = triangle.lines[1].start_point
	else:
		point3 = triangle.lines[1].end_point
	var mesh: CSGPolygon3D = triangle_scene.instantiate()
	mesh.polygon = PackedVector2Array([point1, point2, point3])
	mesh.position.x = 0
	mesh.position.z = 0
	self.add_child(mesh)

func _show_biome_line(line: BiomeLine) -> void:
	var mesh: MeshInstance3D = line_scene.instantiate()
	mesh.mesh.resource_local_to_scene = true
	mesh.mesh.size.x = line.get_length()
	mesh.rotation.y = line.get_rotation()
	mesh.position.x = line.get_middle().x
	mesh.position.y += 0
	mesh.position.z = line.get_middle().y
	self.add_child(mesh)
