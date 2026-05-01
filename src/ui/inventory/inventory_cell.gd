class_name InventoryCell
extends PanelContainer


@export var subviewport: SubViewport
@export var count_label: RichTextLabel
var items: Array[Node3D]
var type: ItemDescription


func add_item(item: ItemDescription):
	if len(items)==0:
		item.main_node.reparent(subviewport)
		item.main_node.global_position = Vector3.ZERO
		type = item
	else:
		item.main_node.get_parent().remove_child(item.main_node)
	items.push_back(item.main_node)
	update_count_label()


func remove_item(quantity: int) -> int:
	var diff = len(items)-quantity
	for i in clampi(quantity, 0, len(items)):
		var popped_item = items.pop_back()
		popped_item.queue_free()
	update_count_label()
	return max(0, -diff)


func get_item_name() -> String:
	if is_empty():
		return ""
	return type.item_name


func is_empty() -> bool:
	return items.is_empty()


func update_count_label():
	count_label.text = str(len(items))
	count_label.visible = len(items)>0
