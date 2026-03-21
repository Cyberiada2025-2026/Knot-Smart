class_name InteractableZone
extends Node3D


@export_enum("TAKE", "PUT") var interact_type: String
@export var items: Array[ItemDescription] = []

const SCALE_VECTOR = Vector3(1.2, 1.2, 1.2)
const COLLISION_MASK = 2

func _ready() -> void:
	var zone: Area3D
	for i in range(len(items)):
		var item = items[i].duplicate()
		item.main_node = get_parent()
		items[i] = item
	if interact_type == "TAKE":
		zone = TakeItemZone.new()
		zone.item = items.front()
	else:
		zone = PutItemZone.new()
		zone.items = items
	for sibling in get_parent().find_children("", "CollisionShape3D"):
			zone.add_child(sibling.duplicate())
			break
	zone.collision_mask = COLLISION_MASK
	zone.transform = zone.transform.scaled(SCALE_VECTOR)
	add_child(zone)
