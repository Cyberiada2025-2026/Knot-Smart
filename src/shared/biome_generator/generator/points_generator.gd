@tool
class_name PointsGenerator
extends Node3D


@export var generator_main: PlantsWallsGenerator

var params: PlantWallGeneratorParams
var data: PlantWallsSaver



func generate() -> void:
	params = generator_main.params
	data = generator_main.data
	_create_point_grid()
	_randomize_points()

func reset() -> void:
	params = generator_main.params
	data = generator_main.data
	data.points.clear()

func _get_step_size_x() -> float:
	return (params.size.x / (params.points_in.x - 1))

func _get_step_size_z() -> float:
	return (params.size.y / (params.points_in.y - 1))

func _create_point_grid() -> void:
	for z: int in range(params.points_in.y):
		for x: int in range(params.points_in.x):
			data.points[Vector2(x, z)] = Vector2(
				(x) * _get_step_size_x() + params.start.x,
				(z) * _get_step_size_z() + params.start.y
			)


func _randomize_points() -> void:
	for z: int in range(
		params.randomization_margin,
		params.points_in.y - params.randomization_margin
	):
		for x: int in range(
			params.randomization_margin,
			params.points_in.x - params.randomization_margin
		):
			data.points[Vector2(x, z)].x += (
				_get_step_size_x() * (data.rng.randf() - 0.5) * params.randomization_strength.x
			)
			data.points[Vector2(x, z)].y += (
				_get_step_size_z() * (data.rng.randf() - 0.5) * params.randomization_strength.y
			)
