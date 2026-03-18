extends Node

var prev_mouse_mode

var entry_scene = preload("uid://dktjlwqp00lcr")

var pages: Control
var buttons: Control
@onready var button_normal = $"Button container/Button".get_theme_stylebox("normal", "Button")

func add_object(obj_des:ObjectDescription):
	var page = pages.get_child(obj_des.page_no).get_child(1).get_child(0)
	var entry = entry_scene.instantiate()
	page.add_child(entry)
	var camera = entry.get_child(0).get_child(0).get_child(1)
	var model = obj_des.model
	model.set_scale(Vector3(obj_des.scale, obj_des.scale, obj_des.scale))
	model.set_position(Vector3(0.0, 0.0, -0.4)) #ideal position to see model
	camera.add_child(model)
	var obj_text = entry.get_child(1)
	obj_text.append_text("[b]" + obj_des.object_name + "[/b]\n" + obj_des.description)

func _ready() -> void:
	pages = $"Page container"
	buttons = $"Button container"


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("journal_show"):
		if not (get_tree().paused == true and self.visible == false):
			if self.visible == true:
				get_tree().paused = false
				self.visible = false
				Input.set_mouse_mode(prev_mouse_mode)
			else:
				get_tree().paused = true
				self.visible = true
				prev_mouse_mode = Input.get_mouse_mode()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed(number: int) -> void:
	var button: Button = buttons.get_child(number)
	if pages.get_child(number).visible == false:
		for i in range(pages.get_child_count()):
			pages.get_child(i).set_visible(false)
			buttons.get_child(i).add_theme_stylebox_override("normal", button_normal)
		pages.get_child(number).set_visible(true)
		button.add_theme_stylebox_override("normal", button.get_theme_stylebox("pressed", "Button"))
