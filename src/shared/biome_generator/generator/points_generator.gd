@tool
class_name PointsGenerator
extends Node3D


@export var generator_main: PlantsWallsGenerator
@export_category("GeneratorVariables")
## number of points from border that will not be affected by randomization
@export var randomization_margin: int = 0
## percentage of half averange distance
@export var randomization_strength: Vector2 = Vector2(0.99, 0.99)


var points: Dictionary[Vector2, Vector2] = {}

func generate() -> void:
	_create_point_grid()
	_randomize_points()

func reset() -> void:
	points.clear()

func _get_step_size_x() -> float:
	return (generator_main.size.x / (generator_main.points_in.x - 1))

func _get_step_size_z() -> float:
	return (generator_main.size.y / (generator_main.points_in.y - 1))

func _create_point_grid() -> void:
	for z: int in range(generator_main.points_in.y):
		for x: int in range(generator_main.points_in.x):
			points[Vector2(x, z)] = Vector2(
				(x) * _get_step_size_x() + generator_main.start.x,
				(z) * _get_step_size_z() + generator_main.start.y
			)


func _randomize_points() -> void:
	for z: int in range(
		randomization_margin,
		generator_main.points_in.y - randomization_margin
	):
		for x: int in range(
			randomization_margin,
			generator_main.points_in.x - randomization_margin
		):
			points[Vector2(x, z)].x += (
				_get_step_size_x() * (generator_main.rng.randf() - 0.5) * randomization_strength.x
			)
			points[Vector2(x, z)].y += (
				_get_step_size_z() * (generator_main.rng.randf() - 0.5) * randomization_strength.y
			)
