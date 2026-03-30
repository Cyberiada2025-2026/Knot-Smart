@tool
class_name RoomGenerationParams
extends Resource

const MAX_RANDOM_SEED = 10000

@export var mesh_library: MeshLibrary
@export var grid_cell_size: Vector3 = Vector3.ONE
@export var can_enter: bool = true
@export var min_room_size: Vector3i = Vector3i(1, 1, 1)
@export var max_room_size: Vector3i = Vector3i(4, 1, 3)
@export_range(0, 1) var long_room_tendency: float = 0.2
@export var outside_door_count: int = 1
@export_range(0, 1) var window_percentage: float = 0.3
@export var random_seed: int = randi_range(0, MAX_RANDOM_SEED)
@export_tool_button("Randomize Seed")
var randomize_seed_action = func(): self.random_seed = randi_range(0, MAX_RANDOM_SEED)
