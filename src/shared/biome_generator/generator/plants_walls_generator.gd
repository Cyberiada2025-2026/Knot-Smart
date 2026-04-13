@tool
class_name PlantsWallsGenerator
extends Node3D

@export_tool_button("Generate")var generate_func: Callable = regenerate
@export_tool_button("Randomize seed")var seed_func: Callable = regenerate_seed
@export var path: String = "res://biomegenerator.tscn"

@export var walls_combiner: WallsCombiner
@export_category("SubGenerators")
@export var points_generator: PointsGenerator
@export var triangle_generator: TriangleGenerator

@export_category("GeneratorVariables")
@export var custom_seed: int = 0
@export_group("location")
@export var size: Vector2 = Vector2(200, 200)
@export var start: Vector2 = Vector2(-100, -100)
@export_group("points")
## number of points in x/z
@export var points_in: Vector2 = Vector2(50, 50)

var rng: RandomNumberGeneratorUpgraded

func regenerate() -> void:
	reset()
	generate()
	#var scene: PackedScene = PackedScene.new()
	#scene.pack(generator)
	#ResourceSaver.save(scene, path)

func regenerate_seed() -> void:
	custom_seed = rng.randi()

func _set_rng():
	rng = RandomNumberGeneratorUpgraded.new()
	if custom_seed == 0:
		rng.randomize()
	else:
		rng.seed = custom_seed

func generate() -> void:
	points_generator.generate_points()
	triangle_generator.generate_lines_and_triangles()

func reset() -> void:
	_set_rng()
	points_generator.reset()
	triangle_generator.reset()
