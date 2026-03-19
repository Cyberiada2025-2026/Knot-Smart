extends HBoxContainer

var model: Node3D = null


func add_entry(obj_des: ObjectDescription) -> void:
	model = obj_des.model
	model.set_scale(Vector3(obj_des.object_scale, obj_des.object_scale, obj_des.object_scale))
	model.set_position(Vector3(0.0, 0.0, 0.0))  #to ensure model is at the right place
	$"SubViewportContainer/SubViewport".add_child(model)
	var obj_text = $"RichTextLabel"
	obj_text.text += ("[b]" + obj_des.object_name + "[/b]\n" + obj_des.description)


func _process(_delta: float) -> void:
	if model != null:
		model.rotate_y(0.1)
