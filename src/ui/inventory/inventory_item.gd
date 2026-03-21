class_name InventoryCell
extends PanelContainer


@export var subviewport: SubViewport
var num: int = 0
var items: Array[ItemDescription]


func _ready() -> void:
	pass
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


func add_item(item: ItemDescription):
	items.push_back(item)
	item.parent.reparent(subviewport)
	item.parent.global_position = Vector3.ZERO
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
