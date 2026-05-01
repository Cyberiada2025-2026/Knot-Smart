@tool
class_name TakeItemZone
extends Node3D

@export var item: ItemDescription


func _ready() -> void:
	var item_copy = item.duplicate()
	item_copy.main_node = get_parent()
	item = item_copy


func get_items() -> Dictionary[ItemDescription, int]:
	var items: Dictionary[ItemDescription, int] = {}
	items[item] = 1
	return items
