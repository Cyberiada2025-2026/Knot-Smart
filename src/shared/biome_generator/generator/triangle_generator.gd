@tool
class_name TriangleGenerator
extends Node3D



@export var generator_main: PlantsWallsGenerator

var params: PlantWallGeneratorParams
var data: PlantWallsSaver



func reset() -> void:
	params = generator_main.params
	data = generator_main.data
	data.lines.clear()
	data.triangles.clear()

func generate() -> void:
	params = generator_main.params
	data = generator_main.data
	_set_lines_and_triangles(data.points)

func _set_lines_and_triangles(points: Dictionary[Vector2, Vector2]) -> void:
	# Horizontal lines
	for z: int in range(params.points_in.y):
		for x: int in range(params.points_in.x - 1):
			data.lines[Vector3(x, z, data.HORIZONTAL_LINE)] = _create_line(
				points[Vector2(x, z)],
				points[Vector2(x + 1, z)]
			)
	# Vertical lines
	for z: int in range(params.points_in.y - 1):
		for x: int in range(params.points_in.x):
			data.lines[Vector3(x, z, data.VERTICAL_LINE)] = _create_line(
				points[Vector2(x, z)],
				points[Vector2(x, z + 1)]
			)
	# Middle lines and triangles
	for z: int in range(params.points_in.y - 1):
		for x: int in range(params.points_in.x - 1):
			var chosen_diagonal_line: int = data.rng.randi()%2
			data.lines[Vector3(x, z, data.DIAGONAL_LINE)] = _create_line(
				points[Vector2(x+(1-chosen_diagonal_line), z)],
				points[Vector2(x+chosen_diagonal_line, z+1)]
			)
			_create_triangles_from_lines(x, z, chosen_diagonal_line)


func _create_triangles_from_lines(x: int, z: int, chosen_diagonal_line: int) -> void:
	_create_upper_triangle_from_lines(x, z, chosen_diagonal_line)
	_create_lower_triangle_from_lines(x, z, chosen_diagonal_line)


func _create_upper_triangle_from_lines(x: int, z: int, chosen_middle_line: int) -> void:
	data.triangles.append(
		_create_triangle(
			data.lines[Vector3(x, z, data.HORIZONTAL_LINE)],
			data.lines[Vector3((x + chosen_middle_line), z, data.VERTICAL_LINE)],
			data.lines[Vector3(x, z, data.DIAGONAL_LINE)]
		)
	)


func _create_lower_triangle_from_lines(x: int, z: int, chosen_middle_line: int) -> void:
	data.triangles.append(
		_create_triangle(
			data.lines[Vector3(x, (z+1), data.HORIZONTAL_LINE)],
			data.lines[Vector3((x + 1 - chosen_middle_line), z, data.VERTICAL_LINE)],
			data.lines[Vector3(x, z, data.DIAGONAL_LINE)]
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
