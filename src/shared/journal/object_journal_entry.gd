extends HBoxContainer

@export var text: RichTextLabel
@export var subview: Node
var rotate_angle
var model: Node3D = null


func add_entry(entry_poi: JournalEntryPOI) -> void:
	if entry_poi.model != null:
		model = entry_poi.model
		model.set_scale(
			Vector3(entry_poi.model_scale, entry_poi.model_scale, entry_poi.model_scale)
		)
		model.set_position(Vector3.ZERO)  #to ensure model is at the right place
		subview.add_child(model)
	text.text += ("[b]" + entry_poi.object_name + "[/b]\n" + entry_poi.description)
	rotate_angle = entry_poi.rotation_angle


func _process(delta: float) -> void:
	if model != null:
		model.rotate_y(rotate_angle * delta)
