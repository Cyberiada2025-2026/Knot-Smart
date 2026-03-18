extends HBoxContainer

var model: Node3D

func add_entry(obj_des: ObjectDescription) -> void:
	var model = obj_des.model
	model.set_scale(Vector3(obj_des.scale, obj_des.scale, obj_des.scale))
	model.set_position(Vector3(0.0, 0.0, -0.4)) #ideal position to see model
	$"SubViewportContainer/SubViewport/Camera2D".add_child(model)
	var obj_text = $"RichTextLabel"
	obj_text.append_text("[b]" + obj_des.object_name + "[/b]\n" + obj_des.description)
	

func _ready() -> void:
	model = null

func _process(_delta: float) -> void:
	if(model!=null):
		model.rotate_y(0.1)
