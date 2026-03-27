@tool
class_name PutItemZone
extends Node3D


@export var items: Array[ItemDescription] = []:
	set(value):
		items = value
		for item in items:
			item.quantity_show = true
@export var collider_scale = Vector3(1.5, 1.5, 1.5)
@export var zone: InteractableZone


func _ready() -> void:
	zone.items = items
	zone.collider_scale = collider_scale
	zone.interact_type = "PUT"
	zone.set_zone()
