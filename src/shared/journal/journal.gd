## Manages the journal system
extends Node

var prev_mouse_mode

var is_visible: bool = false
var menu: Control
var pages: Control
var button_normal
var added_information: Array[bool] = [0, 0, 0, 0]
var models: Array[Node3D]

func add_object(description: String, name:String, model:Node3D, page_no: int):
	var page = pages.get_child(page_no).get_child(1).get_child(0)
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.set_custom_minimum_size(Vector2(220,100))
	hbox.add_theme_constant_override("Separator",0)
	page.add_child(hbox)
	var subviewcont: SubViewportContainer = SubViewportContainer.new()
	hbox.add_child(subviewcont)
	var subview: SubViewport = SubViewport.new()
	subview.set_size(Vector2i(100,100))
	subview.own_world_3d=true
	subview.transparent_bg=true
	subviewcont.add_child(subview)
	var spotlight: SpotLight3D = SpotLight3D.new()
	spotlight.set_position(Vector3(0.11,0.51,0.24))
	subview.add_child(spotlight)
	var camera:Camera3D = Camera3D.new()
	subview.add_child(camera)
	#var model1 = load("res://characters/player/player_model.glb")
	#var model = model1.instantiate()
	model.set_scale(Vector3(0.3,0.3,0.3))
	model.set_position(Vector3(0.0,0.0,-0.4))
	camera.add_child(model)
	models.append(model)
	
	var obj_text: RichTextLabel = RichTextLabel.new()
	obj_text.set_custom_minimum_size(Vector2(120, 100))
	obj_text.push_color(Color(0.9, 0.5, 0.5))
	obj_text.add_text(name + "\n" + description)
	hbox.add_child(obj_text)
	

func _ready() -> void:
	menu = $"Journal menu"
	pages = menu.get_child(1)
	#menu.get_node("Button container/Page co")
	button_normal = menu.get_child(0).get_child(1).get_theme_stylebox("normal", "Button")
	#model=get_child(0).get_child(1).get_child(0).get_child(1).get_child(0).get_child(0).get_child(0).get_child(0).get_child(1).get_child(0)
	models.append($"Journal menu/Page container/Page1/ScrollContainer/VBoxContainer/HBoxContainer/SubViewportContainer/SubViewport/Camera2D/player_model")
	
	
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("journal_show"):
		print("click1")
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
	print(number + 1)

	if pages.get_child(number).visible == false:
		for i in range(pages.get_child_count()):
			pages.get_child(i).set_visible(false)
			menu.get_child(0).get_child(i).add_theme_stylebox_override("normal", button_normal)

		pages.get_child(number).set_visible(true)
		button.add_theme_stylebox_override("normal", button.get_theme_stylebox("pressed", "Button"))
