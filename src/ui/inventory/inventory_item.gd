class_name InventoryCell
extends PanelContainer


@export var subviewport: SubViewport
@export var text_label: RichTextLabel
var num: int = 0
var items: Array[ItemDescription]


func add_item(item: ItemDescription):
	items.push_back(item)
	if num==0:
		item.main_node.reparent(subviewport)
		item.main_node.global_position = Vector3.ZERO
	else:
		item.main_node.get_parent().remove_child(item.main_node)
	num+=1
	on_item_num_changed()


func remove_item(item: ItemDescription):
	for i in clampi(item.quantity, 0, num):
		var popped_item = items.pop_back()
		popped_item.main_node.queue_free()
	var diff = num-item.quantity
	num = 0 if diff<0 else diff
	item.quantity = 0 if diff>=0 else -diff
	on_item_num_changed()


func get_type() -> String:
	if is_empty():
		return ""
	return items.front().item_name


func is_empty() -> bool:
	return num == 0


func on_item_num_changed():
	text_label.text = str(num)
	text_label.visible = true if num>0 else false
