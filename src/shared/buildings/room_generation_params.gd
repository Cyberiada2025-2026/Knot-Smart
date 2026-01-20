extends Resource
class_name RoomGenerationParams

@export var min_room_size: Vector3i = Vector3i(1, 1, 1)
@export var room_split_direction_randomizer: int = 1
@export var room_split_position_randomizer: int = 1
@export var max_room_size: Vector3i = Vector3i(4, 1, 3)
@export var entrance_count: int = 1
@export_range(0,1) var window_percentage: float = 0.3
