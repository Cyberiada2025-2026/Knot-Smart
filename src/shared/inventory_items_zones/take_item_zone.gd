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


func change_items(cell, _item) -> bool:
	if cell.get_item_name()==item.item_name or cell.is_empty():
		cell.add_item(item)
		return true
	return false
