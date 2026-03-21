class_name InventoryCell
extends Control


@export var subviewport: SubViewport
var num: int = 0
var items: Array[ItemDescription]


func _ready() -> void:
	var box = ColorRect.new()
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(box)


func add_item(item: ItemDescription):
	item.parent.get_parent().remove_child(item.parent)
	items.push_back(item)
	num+=1


func remove_item() -> ItemDescription:
	num = 0 if num == 0 else num-1
	return items.pop_back()


func get_type() -> String:
	if is_empty():
		return ""
	return items.front().item_name


func is_empty() -> bool:
	return num == 0
