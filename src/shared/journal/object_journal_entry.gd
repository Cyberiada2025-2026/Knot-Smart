extends HBoxContainer

@export var text: RichTextLabel
@export var subview: Node
var rotate_angle
var model: Node3D = null


func add_entry(entry_poi: JournalEntryPOI) -> void:
	var entry = entry_poi.journal_entry
	var entry_model = entry_poi.get_node(entry.model_path)

	subview.get_parent().visible = entry_model != null
	if entry_model != null:
		model = entry_model.duplicate()
		model.scale = Vector3.ONE * entry.model_scale
		model.position = Vector3.ZERO #to ensure model is at the right place
		subview.add_child(model)

	text.text += ("[b]" + entry.object_name + "[/b]\n" + entry.description)
	rotate_angle = entry.rotation_angle


func _process(delta: float) -> void:
	if model != null:
		model.rotate_y(rotate_angle * delta)
