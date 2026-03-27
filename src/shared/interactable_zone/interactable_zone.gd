@tool
class_name InteractableZone
extends Area3D

## Same as player collision layer
const COLLISION_MASK = 2

var interact_type: String
var items: Array[ItemDescription] = []
var collider_scale = Vector3(1.5, 1.5, 1.5)
var inventory_manager: InventoryManager


func set_zone() -> void:
	if not Engine.is_editor_hint():
		inventory_manager = get_tree().root.find_child("InventoryManager", true, false)
		body_entered.connect(_on_area_3d_body_entered)
		body_exited.connect(_on_area_3d_body_exited)
		for i in range(len(items)):
			var item = items[i].get_copy()
			item.main_node = get_parent().get_parent()
			items[i] = item
		for sibling in get_parent().get_parent().find_children("", "CollisionShape3D"):
			add_child(sibling.duplicate())
			break
		collision_mask = COLLISION_MASK
		transform = transform.scaled(collider_scale)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	set_items(true)


func _on_area_3d_body_exited(_body: Node3D) -> void:
	set_items(false)


func set_items(can_interact: bool):
	inventory_manager.set_items(can_interact, items, interact_type)
