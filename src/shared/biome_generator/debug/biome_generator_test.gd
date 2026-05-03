@tool
extends Node3D

@export_tool_button("generate")var generate_func: Callable = generate
@export_tool_button("set_seed_to_random")var seed_func: Callable = change_seed
@export var generator: BiomeGenerator
@export var path: String = "res://biomegenerator.tscn"

func generate() -> void:
	generator.reset()
	generator.generate()
	var scene: PackedScene = PackedScene.new()
	scene.pack(generator)
	ResourceSaver.save(scene, path)

func change_seed() -> void:
	generator.custom_seed = String.num(randf()) + String.num(randf())

func _ready() -> void:
	var scene: PackedScene = ResourceLoader.load(path)
	if scene != null:
		generator.queue_free()
		generator = scene.instantiate()
		self.add_child(generator)
		generator.owner = get_tree().edited_scene_root
