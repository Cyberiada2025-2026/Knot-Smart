extends HBoxContainer

@export var text: RichTextLabel
@export var subview: Node
var rotate_angle
var model: Node3D = null


func add_entry(obj_des: JournalEntryPOI) -> void:
	model = obj_des.model
	model.set_scale(Vector3(obj_des.model_scale, obj_des.model_scale, obj_des.model_scale))
	model.set_position(Vector3.ZERO)  #to ensure model is at the right place
	subview.add_child(model)
	text.text += ("[b]" + obj_des.object_name + "[/b]\n" + obj_des.description)
	rotate_angle = obj_des.rotation_angle


func _process(delta: float) -> void:
	if model != null:
		model.rotate_y(rotate_angle * delta)
