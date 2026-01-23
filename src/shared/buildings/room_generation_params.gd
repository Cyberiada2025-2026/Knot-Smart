class_name RoomGenerationParams
extends Resource

@export var min_size: Vector3i = Vector3i(1, 1, 1)
@export var max_size: Vector3i = Vector3i(4, 1, 3)
@export var split_dir_rand: int = 1
@export var split_pos_rand: int = 1
@export var entrance_count: int = 1
@export_range(0, 1) var window_percentage: float = 0.3
