extends Node

var prev_mouse_mode

var entry_scene = preload("res://shared/journal/journal_entry.tscn")

var is_visible: bool = false
var menu: Control
var pages: Control
var button_normal
var models: Array[Node3D]


func add_object(description: String, name: String, model: Node3D, page_no: int, scale: float):
	var page = pages.get_child(page_no).get_child(1).get_child(0)
	var entry = entry_scene.instantiate()
	page.add_child(entry)
	var camera = entry.get_child(0).get_child(0).get_child(1)
	model.set_scale(Vector3(scale, scale, scale))
	model.set_position(Vector3(0.0, 0.0, -0.4))
	camera.add_child(model)
	models.append(model)
	var obj_text = entry.get_child(1)
	obj_text.append_text("[b]" + name + "[/b]\n" + description)


func _ready() -> void:
	menu = $"Journal menu"
	pages = menu.get_child(1)
	button_normal = menu.get_child(0).get_child(1).get_theme_stylebox("normal", "Button")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("journal_show"):
		if not (get_tree().paused == true and menu.visible == false):
			if menu.visible == true:
				get_tree().paused = false
				menu.visible = false
				Input.set_mouse_mode(prev_mouse_mode)
			else:
				get_tree().paused = true
				menu.visible = true
				prev_mouse_mode = Input.get_mouse_mode()
				Input.set_mouse_mode(0)

	for model in models:
		model.rotate_y(0.1)


func _on_button_pressed(number: int) -> void:
	var button: Button = menu.get_child(0).get_child(number)

	if pages.get_child(number).visible == false:
		for i in range(pages.get_child_count()):
			pages.get_child(i).set_visible(false)
			menu.get_child(0).get_child(i).add_theme_stylebox_override("normal", button_normal)

		pages.get_child(number).set_visible(true)
		button.add_theme_stylebox_override("normal", button.get_theme_stylebox("pressed", "Button"))
