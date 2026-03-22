@tool
extends Node3D

@export_tool_button("generate")var generate_func: Callable = generate
@export_tool_button("set_seed_to_random")var seed_func: Callable = change_seed
@export var generator_scene: PackedScene
var generator: BiomeGenerator

func generate() -> void:
	if generator == null:
		generator = generator_scene.instantiate()
		self.add_child(generator)
	generator.reset()
	generator.generate()

func change_seed() -> void:
	generator.custom_seed = String.num(randf()) + String.num(randf())

func _ready() -> void:
	generator = generator_scene.instantiate()
	self.add_child(generator)
	generate()
