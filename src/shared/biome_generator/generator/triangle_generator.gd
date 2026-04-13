@tool
class_name TriangleGenerator
extends Node3D

const VERTICAL_LINE = 0
const HORIZONTAL_LINE = 1
const DIAGONAL_LINE = 2


@export var generator_main: PlantsWallsGenerator
@export_category("GeneratorVariables")
@export_group("triangles selection")
## chance to shuffle possible triangles, during every selection of next biome triangle
@export var chance_to_shuffle: float = 0.01

## Dictionary with x,y beeing position and z representing type of line
var lines: Dictionary[Vector3, BiomeLine]
var triangles: Array[BiomeTriangle]

func reset() -> void:
	lines.clear()
	triangles.clear()

func generate_lines_and_triangles() -> void:
	_set_lines_and_triangles(generator_main.points_generator.points)

func _set_lines_and_triangles(points: Dictionary[Vector2, Vector2]) -> void:
	# Horizontal lines
	for z: int in range(generator_main.points_in.y):
		for x: int in range(generator_main.points_in.x - 1):
			lines[Vector3(x, z, HORIZONTAL_LINE)] = _create_line(
				points[Vector2(x, z)],
				points[Vector2(x + 1, z)]
			)
	# Vertical lines
	for z: int in range(generator_main.points_in.y - 1):
		for x: int in range(generator_main.points_in.x):
			lines[Vector3(x, z, VERTICAL_LINE)] = _create_line(
				points[Vector2(x, z)],
				points[Vector2(x, z + 1)]
			)
	# Middle lines and triangles
	for z: int in range(generator_main.points_in.y - 1):
		for x: int in range(generator_main.points_in.x - 1):
			var chosen_diagonal_line: int = generator_main.rng.randi()%2
			lines[Vector3(x, z, DIAGONAL_LINE)] = _create_line(
				points[Vector2(x+(1-chosen_diagonal_line), z)],
				points[Vector2(x+chosen_diagonal_line, z+1)]
			)
			_create_triangles_from_lines(x, z, chosen_diagonal_line)


func _create_triangles_from_lines(x: int, z: int, chosen_diagonal_line: int) -> void:
	_create_upper_triangle_from_lines(x, z, chosen_diagonal_line)
	_create_lower_triangle_from_lines(x, z, chosen_diagonal_line)


func _create_upper_triangle_from_lines(x: int, z: int, chosen_middle_line: int) -> void:
	triangles.append(
		_create_triangle(
			lines[Vector3(x, z, HORIZONTAL_LINE)],
			lines[Vector3((x + chosen_middle_line), z, VERTICAL_LINE)],
			lines[Vector3(x, z, DIAGONAL_LINE)]
		)
	)


func _create_lower_triangle_from_lines(x: int, z: int, chosen_middle_line: int) -> void:
	triangles.append(
		_create_triangle(
			lines[Vector3(x, (z+1), HORIZONTAL_LINE)],
			lines[Vector3((x + 1 - chosen_middle_line), z, VERTICAL_LINE)],
			lines[Vector3(x, z, DIAGONAL_LINE)]
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
