@tool
class_name PlantsWallsGenerator
extends Node3D

@export_tool_button("Generate")var generate_func: Callable = regenerate
@export_tool_button("Randomize seed")var seed_func: Callable = regenerate_seed
@export_tool_button("Save")var save_func: Callable = save_data
@export_tool_button("Load")var load_func: Callable = load_data


@export var params: PlantWallGeneratorParams
@export_subgroup("SubGenerators")
@export var points_generator: PointsGenerator
@export var triangle_generator: TriangleGenerator
@export var biome_generator: BiomeGenerator
@export var walls_generator: BiomeWallsGenerator
@export var passage_generator: PassagesGenerator


var data: PlantWallsSaver


func regenerate() -> void:
	if data != null:
		data.queue_free()
	data = PlantWallsSaver.new()
	add_child(data)
	reset()
	_generate()


func _set_rng():
	data.rng = RandomNumberGeneratorUpgraded.new()
	if params.custom_seed == 0:
		data.rng.randomize()
	else:
		data.rng.seed = params.custom_seed

func _generate() -> void:
	points_generator.generate()
	triangle_generator.generate()
	biome_generator.generate()
	walls_generator.generate()
	passage_generator.generate()

func reset() -> void:
	_set_rng()
	points_generator.reset()
	triangle_generator.reset()
	biome_generator.reset()
	walls_generator.reset()
	passage_generator.reset()

func regenerate_seed() -> void:
	params.regenerate_seed()

func load_data() -> void:
	if data == null:
		data = PlantWallsSaver.new()
	var path: String = data.get_file_path()
	if data != null:
		data.queue_free()
	var loded_data : PackedScene = load(path)
	data = loded_data.instantiate()
	add_child(data)
	params.custom_seed = data.custom_seed
	_set_rng()

func save_data() -> void:
	data.custom_seed = params.custom_seed
	data.save()
