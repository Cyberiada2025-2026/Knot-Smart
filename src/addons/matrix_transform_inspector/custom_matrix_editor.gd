@tool
extends VBoxContainer

class Data: 
	var translation: Vector3 = Vector3.ZERO
	var rotation: Vector3 = Vector3.ZERO
	var scale: Vector3 = Vector3.ONE


signal property_changed(new_matrix: Projection)


var data: Data = Data.new() 
var map: Dictionary

func get_matrix() -> Projection:
	var matrix = Transform3D(
		Basis.from_euler(data.rotation),
		data.translation
	).scaled_local(data.scale)

	return Projection(matrix)

func _init() -> void:
	_update_inspector()


func _update_inspector() -> void:
	for ed in get_children():
		ed.queue_free()

	for prop in data.get_property_list():
		if not prop["name"] in ["translation", "rotation", "scale"]:
			continue
		var ed: EditorProperty

		if prop["name"] == "scale":
			prop["hint"] = PROPERTY_HINT_LINK 
		ed = EditorInspector.instantiate_property_editor(
				data,
				prop["type"],
				prop["name"],
				prop["hint"],
				prop["hint_string"],
				prop["usage"])

		add_child(ed)
		ed.set_object_and_property(data, prop["name"])
		ed.label = prop["name"]
		ed.property_changed.connect(_prop_changed)
		ed.update_property()
		map[prop["name"]] = ed



func _prop_changed(p_property: String, p_value, p_field: StringName, p_changing: bool) -> void:
	data.set(p_property, p_value)
	if typeof(p_value) >= TYPE_ARRAY:
		map[p_property].update_property()

