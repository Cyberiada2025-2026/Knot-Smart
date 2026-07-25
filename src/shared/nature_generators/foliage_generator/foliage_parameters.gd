@tool
class_name FoliageParameters
extends Resource

@export_tool_button("Randomize seed", "Callable") var random_seed_button = on_random_seed
@export var seed: int = randi()
@export var mesh: PackedScene
@export_range(1, 5, 1) var count: int = 2
@export_range(0.5, 5.0, 0.5) var scale: float = 1.0
@export_range(0.0, 5.0, 0.5) var scale_randomization: float = 1.0

func on_random_seed():
	seed = randi()
