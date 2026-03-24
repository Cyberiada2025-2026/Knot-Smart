class_name InventoryCell
extends PanelContainer


@export var subviewport: SubViewport
@export var text_label: RichTextLabel
var items: Array[ItemDescription]


func add_item(item: ItemDescription):
	if len(items)==0:
		item.main_node.reparent(subviewport)
		item.main_node.global_position = Vector3.ZERO
	else:
		item.main_node.get_parent().remove_child(item.main_node)
	items.push_back(item)
	on_item_num_changed()


func remove_item(item: ItemDescription):
	var diff = len(items)-item.quantity
	for i in clampi(item.quantity, 0, len(items)):
		var popped_item = items.pop_back()
		popped_item.main_node.queue_free()
	item.quantity = max(0, -diff)
	on_item_num_changed()


func get_type() -> String:
	if is_empty():
		return ""
	return items.front().item_name


func is_empty() -> bool:
	return items.is_empty()


func on_item_num_changed():
	text_label.text = str(len(items))
	text_label.visible = len(items)>0
