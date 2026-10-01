@tool
class_name ItemPlacer
extends Node3D

var items: Array[String] = []
var items_nodes: Array[Node] = []

@export_tool_button("Place Item","Callable") var place_button = place_item
@export_group("Object properties")
@export_subgroup("Randomise position")
@export_tool_button("Random position","Callable") var position_button = random_position
@export var size_of_random_generator: int = 10
@export_group("Object properties")
@export var object_position: Vector3 = Vector3.ZERO
@export var object_rotation: Vector3 = Vector3.ZERO
@export var object_scale: Vector3 = Vector3.ZERO

var internal_value: String = "Not selected"

func _ready() -> void:
	var items_scene = load("res://shared/item_placer/items_to_place.tscn").instantiate()
	items_nodes = items_scene.get_children()
	for item in items_nodes:
		items.append(item.get_name())
	notify_property_list_changed()

func _get_property_list():
	var properties: Array[Dictionary] = []
	var hint_string = ",".join(items)
	properties.append({
		"name": "Items",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hint_string,
	})

	return properties
	
	
func _get(property: StringName) -> Variant:
	if property == "Items":
		return internal_value
	return null

func _set(property, value):
	if property == "Items":
		internal_value = value
		return true
	return false

func place_item():
	if (internal_value=="Not selected"):
		print("Select an object to place")
		pass
	var item_to_place = items_nodes[items.find(internal_value)].duplicate()
	print(item_to_place)
	item_to_place.position = object_position
	item_to_place.rotation = object_rotation
	item_to_place.scale = scale
	item_to_place.visible = true
	add_child(item_to_place)
	item_to_place.set_owner(self)
	
func random_position():
	var rng = RandomNumberGenerator.new()
	object_position.x = rng.randf_range(-size_of_random_generator, size_of_random_generator)
	object_position.y = rng.randf_range(-size_of_random_generator, size_of_random_generator)
	object_position.z = rng.randf_range(-size_of_random_generator, size_of_random_generator)
