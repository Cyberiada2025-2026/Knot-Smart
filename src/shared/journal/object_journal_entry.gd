extends HBoxContainer

@export var text: RichTextLabel
@export var subview: Node
var rotate_angle
var model: Node3D = null


func add_entry(entry: JournalEntryDescription) -> void:
	var entry_model = null
	if not entry.model_scene.is_empty():
		entry_model = load(entry.model_scene)

	subview.get_parent().visible = entry_model != null
	if entry_model != null:
		model = entry_model.instantiate()
		model.scale = Vector3.ONE * entry.model_scale
		model.position = Vector3.ZERO  #to ensure model is at the right place
		subview.add_child(model)

	text.text += ("[b]" + entry.object_name + "[/b]\n" + entry.description)
	rotate_angle = entry.rotation_angle


func _process(delta: float) -> void:
	if model != null:
		model.rotate_y(rotate_angle * delta)
