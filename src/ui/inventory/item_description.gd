class_name ItemDescription
extends Node


@export var item_name: String = ""
@export var description: String = ""
@export var model: Node3D
var parent: Node3D


func _ready() -> void:
	parent = get_parent()
	var interact_zone = InteractZone.new()
	interact_zone.item = self
	for sibling in parent.get_children():
		if sibling is CollisionShape3D:
			interact_zone.add_child(sibling.duplicate())
			break
	interact_zone.transform = interact_zone.transform.scaled(Vector3(1.2, 1.2, 1.2))
	add_child(interact_zone)
