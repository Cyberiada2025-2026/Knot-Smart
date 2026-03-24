class_name InteractableZone
extends Area3D


@export_enum("TAKE", "PUT") var interact_type: String
@export var items: Array[ItemDescription] = []
var inventory_manager: InventoryManager
var zone: Node3D

const SCALE_VECTOR = Vector3(1.2, 1.2, 1.2)
const COLLISION_MASK = 2 # same as player collision mask


func _ready() -> void:
	inventory_manager = get_tree().root.find_child("InventoryManager", true, false)
	body_entered.connect(_on_area_3d_body_entered)
	body_exited.connect(_on_area_3d_body_exited)
	for i in range(len(items)):
		var item = items[i].duplicate()
		item.main_node = get_parent()
		items[i] = item
	for sibling in get_parent().find_children("", "CollisionShape3D"):
		add_child(sibling.duplicate())
		break
	collision_mask = COLLISION_MASK
	transform = transform.scaled(SCALE_VECTOR)


func _on_area_3d_body_entered(body: Node3D) -> void:
	set_items(true)


func _on_area_3d_body_exited(body: Node3D) -> void:
	set_items(false)


func set_items(can_interact: bool):
	inventory_manager.set_items(can_interact, items, interact_type)
