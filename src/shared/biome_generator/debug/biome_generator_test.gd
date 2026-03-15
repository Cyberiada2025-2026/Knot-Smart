@tool
extends Node3D

@export_tool_button("generate")var generate_func: Callable = generate
@export var generator_scene: PackedScene
var generator: BiomeGenerator

func generate() -> void:
	print("\n")
	if generator != null:
		generator.queue_free()
	generator = generator_scene.instantiate()
	self.add_child(generator)
	generator.generate()

func _ready() -> void:
	if generator == null:
		generate()
