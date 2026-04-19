@tool
class_name PlantsWallsGenerator
extends Node3D

@export_tool_button("Generate")var generate_func: Callable = regenerate
@export_tool_button("Randomize seed")var seed_func: Callable = regenerate_seed
#@export_tool_button("DEBUG RESET")var debugfun: Callable = debug_reset
@export var path: String = "res://biomegenerator.tscn"

@export_category("Nodes")
@export var saved_nodes_node: Node3D
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


#func debug_reset() -> void:
	#for x in saved_nodes_node.get_children(false):
		#print(x)


func _ready() -> void:
	regenerate()

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
