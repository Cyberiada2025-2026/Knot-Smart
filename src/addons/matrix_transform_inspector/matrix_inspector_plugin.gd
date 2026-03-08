extends EditorInspectorPlugin

var custom_matrix_editor = preload("uid://dxlefn1x1ntlv")

func _can_handle(object: Object) -> bool:
	return object is ShaderMaterial

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if type != TYPE_PROJECTION:
		return false
	var instance = custom_matrix_editor.new()
	add_property_editor(name, instance)
	return true
