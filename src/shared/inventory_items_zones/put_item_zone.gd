@tool
class_name PutItemZone
extends Node3D


@export var items: Dictionary[ItemDescription, int] = {}


func _ready() -> void:
	for item in items.keys():
		var item_copy = item.duplicate()
		var quantity = items[item]
		item_copy.main_node = get_parent()
		items.erase(item)
		items[item_copy] = quantity


func get_items() -> Dictionary[ItemDescription, int]:
	return items
