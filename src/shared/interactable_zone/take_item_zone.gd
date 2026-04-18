@tool
class_name TakeItemZone
extends Node3D

@export var item: ItemDescription
@export var collider_scale = Vector3(1.5, 1.5, 1.5)
@export var zone: InteractableZone


func _ready() -> void:
	zone.items[item] = 1
	zone.collider_scale = collider_scale
	zone.interact_type = "TAKE"
	zone.set_zone()
