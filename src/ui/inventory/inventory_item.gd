class_name InventoryCell
extends PanelContainer


@export var subviewport: SubViewport
@export var text_label: RichTextLabel
var num: int = 0
var items: Array[ItemDescription]


func add_item(item: ItemDescription):
	items.push_back(item)
	if num==0:
		item.parent.reparent(subviewport)
		item.parent.global_position = Vector3.ZERO
	else:
		item.parent.get_parent().remove_child(item.parent)
	num+=1
	on_item_num_changed()


func remove_item() -> ItemDescription:
	num = 0 if num == 0 else num-1
	return items.pop_back()
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
