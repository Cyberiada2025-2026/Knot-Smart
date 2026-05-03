@tool
class_name PlantsWallsGenerator
extends Node3D

@export_tool_button("Generate")var generate_func: Callable = regenerate
@export_tool_button("Randomize seed")var seed_func: Callable = regenerate_seed
@export_tool_button("Save")var save_func: Callable = save
#@export_tool_button("DEBUG RESET")var debugfun: Callable = debug_reset

@export_category("Path")
@export var path_location: String = "user://" #"res://"
@export var path_folder: String = "biomegenerator/"
@export var path_file_name: String = "generated_biome"
@export var path_file_extension: String = ".tscn"
#@export var path: String = "res://biomegenerator/generated_biome.tscn"
@export_category("Nodes")
@export var saved_nodes_node: Node3D
@export var subgenerators_node: Node3D
@export var walls_combiner: WallsCombiner
@export_subgroup("SubGenerators")
@export var points_generator: PointsGenerator
@export var triangle_generator: TriangleGenerator
@export var biome_generator: BiomeGenerator
@export var walls_generator: BiomeWallsGenerator
@export var passage_generator: PassagesGenerator

@export_category("GeneratorVariables")
@export var custom_seed: int = 0
@export_group("location")
@export var size: Vector2 = Vector2(200, 200)
@export var start: Vector2 = Vector2(-100, -100)
@export_group("points")
## number of points in x/z
@export var points_in: Vector2 = Vector2(50, 50)

var rng: RandomNumberGeneratorUpgraded

var biomes: Array[Biome]


func regenerate() -> void:
	reset()
	generate()

func regenerate_seed() -> void:
	custom_seed = rng.randi()

func _set_rng():
	rng = RandomNumberGeneratorUpgraded.new()
	if custom_seed == 0:
		rng.randomize()
	else:
		rng.seed = custom_seed

func generate() -> void:
	points_generator.generate()
	triangle_generator.generate()
	biome_generator.generate()
	walls_generator.generate()
	passage_generator.generate()
	
	saved_nodes_node.owner = self

func reset() -> void:
	_set_rng()
	points_generator.reset()
	triangle_generator.reset()
	biome_generator.reset()
	walls_generator.reset()
	passage_generator.reset()


func save() -> void:
	var path: String = path_location + path_folder + path_file_name + path_file_extension
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error != OK:
			print("BIOME GENERATOR SAVING ERROR: ", error)
	else:
		var error = DirAccess.make_dir_recursive_absolute(path_location + path_folder)
		if error != OK:
			print("BIOME GENERATOR SAVING DIRECTORY ERROR: ", error)
	
	var scene: PackedScene = PackedScene.new()
	scene.pack(self)
	ResourceSaver.save(scene, path)

func load() -> PlantsWallsGenerator:
	var path: String = path_location + path_folder + path_file_name + path_file_extension
	var loded_generator = load(path)
	return loded_generator
