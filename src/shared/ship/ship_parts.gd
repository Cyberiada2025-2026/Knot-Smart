@tool
class_name ShipParts
extends Node3D

signal win

@export var items: Dictionary[ItemDescription, int] = {}


func _ready() -> void:
	for item in items.keys():
		var item_copy = item.duplicate()
		var quantity = items[item]
		item_copy.main_node = get_parent()
		items.erase(item)
		items[item_copy] = quantity
	if Engine.is_editor_hint():
		win.connect(ProgressionManager.win)


func get_items() -> Dictionary[ItemDescription, int]:
	return items


func change_items(cell, item) -> bool:
	if cell.get_item_name()==item.item_name:
		items[item] = cell.remove_item(items[item])
		on_changed()
		return true
	return false


func on_changed():
	for item in items:
		if items[item] != 0:
			return
	win.emit()
