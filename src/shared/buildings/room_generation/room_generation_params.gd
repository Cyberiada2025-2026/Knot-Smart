@tool
class_name RoomGenerationParams
extends Resource

const MAX_RANDOM_SEED = 10000
const MAX_BUILDING_SIZE = Vector3i.ONE * 100

@export_group("Seed")
@export var random_seed: int = randi_range(0, MAX_RANDOM_SEED)
@export_tool_button("Randomize Seed")
var randomize_seed_action = func(): self.random_seed = randi_range(0, MAX_RANDOM_SEED)

@export_group("Building Models")
@export var tileset_manager: BuildingTilesetManager

@export_group("Bulding Generation")
@export var outside_door_count: int = 1
@export_range(0, 1) var window_percentage: float = 0.3

@export_group("Room Generation")
## Generating rooms will allow the building to be entered.
## If unchecked a single static body collision will be generated.
@export var generate_rooms: bool = true:
	set(value):
		generate_rooms = value
		notify_property_list_changed()

var min_room_size: Vector3i = Vector3i(1, 1, 1):
	get():
		return min_room_size if generate_rooms else MAX_BUILDING_SIZE

var max_room_size: Vector3i = Vector3i(4, 1, 3):
	get():
		return max_room_size if generate_rooms else MAX_BUILDING_SIZE

var long_room_tendency: float = 0.2

func get_mesh_library() -> MeshLibrary:
	return tileset_manager.get_tileset(generate_rooms)

func get_grid_size() -> Vector3:
	return tileset_manager.grid_size


func _get_property_list() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	if generate_rooms:
		(
			result
			. append(
				{
					"name": &"min_room_size",
					"type": TYPE_VECTOR3I,
					"usage": PROPERTY_USAGE_DEFAULT,
				}
			)
		)
		(
			result
			. append(
				{
					"name": &"max_room_size",
					"type": TYPE_VECTOR3I,
					"usage": PROPERTY_USAGE_DEFAULT,
				}
			)
		)
		(
			result
			. append(
				{
					"name": &"long_room_tendency",
					"type": TYPE_FLOAT,
					"usage": PROPERTY_USAGE_DEFAULT,
					"hint": PROPERTY_HINT_RANGE,
					"hint_string": "0,1",
				}
			)
		)

	return result
