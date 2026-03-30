@tool
class_name BuildingGenerationParams
extends Resource

const MAX_RANDOM_SEED = 10000

## If unchecked no additional rooms will be generated
@export var can_enter: bool = true
@export var room_generation_params: RoomGenerationParams
@export var mesh_library: MeshLibrary
@export var grid_cell_size: Vector3 = Vector3.ONE
@export var outside_door_count: int = 1
@export_range(0, 1) var window_percentage: float = 0.3

@export var random_seed: int = randi_range(0, MAX_RANDOM_SEED)
@export_tool_button("Randomize Seed")
var randomize_seed_action = func(): self.random_seed = randi_range(0, MAX_RANDOM_SEED)
