## Manages the journal system
extends Node

var is_visible: bool = false
var menu: Node
var pages: Node
var button_normal

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu = get_child(0)
	pages = menu.get_child(1)
	button_normal = menu.get_child(0).get_child(1).get_theme_stylebox("normal", "Button")
	pass # Replace with function body.

func _init() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("journal_show"):
		print("click1")
		if menu.visible == true:
			menu.visible = false
		else:
			menu.visible = true
	
	pass
	
func _physics_process(delta: float) -> void:
	pass

func _on_button_pressed(number: int) -> void:
	var button: Button = menu.get_child(0).get_child(number)
	print(number+1)
	
	for i in range(pages.get_child_count()):
		pages.get_child(i).set_visible(false)
		menu.get_child(0).get_child(i).add_theme_stylebox_override("normal",button_normal)
		
	pages.get_child(number).set_visible(true)
	button.add_theme_stylebox_override("normal",button.get_theme_stylebox("press", "Button"))
	
	print(pages.get_child(number).has_focus())
	pass # Replace with function body.
