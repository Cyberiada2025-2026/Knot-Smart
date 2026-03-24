@tool
class_name ItemDescription
extends Resource


@export var item_name: String = ""
@export var description: String = ""
var quantity: int = 1
var main_node: Node3D
var quantity_show: bool = false:
	set(value):
		if value == quantity_show: return
		quantity_show = value
		notify_property_list_changed()


func get_copy() -> ItemDescription:
	var item = ItemDescription.new()
	item.item_name = item_name
	item.description = description
	item.quantity = quantity
	return item


func _get_property_list():
	if Engine.is_editor_hint():
		var ret =[]
		if quantity_show:
			# This is how you add a normal variable, like String (TYPE_STRING), int (TYPE_INT)...etc
			ret.append({
			"name": &"quantity",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
			})
		return ret
