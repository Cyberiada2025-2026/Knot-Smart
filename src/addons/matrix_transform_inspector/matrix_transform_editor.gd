extends EditorProperty

var property_control = preload("uid://bthaty3fniekd").instantiate()
var current_value = Projection.IDENTITY
var updating = false

func _init() -> void:
	add_child(property_control)
	add_focusable(property_control)

func _update_property() -> void:
	#var new_value = get_edited_object()[get_edited_property()]
	var new_value = property_control.get_matrix()
	print(new_value)
	if new_value == current_value:
		return

	#current_value = new_value
