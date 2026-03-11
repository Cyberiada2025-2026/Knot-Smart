## Manages the journal system
extends Node

var is_visible = false
var menu: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu = get_child(0)
	menu.set_visible(false)
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

func _on_button1_pressed() -> void:
	print("1")
	pass # Replace with function body.

func _on_button2_pressed() -> void:
	print("2")
	pass # Replace with function body.

func _on_button3_pressed() -> void:
	print("3")
	pass # Replace with function body.

func _on_button4_pressed() -> void:
	print("4")
	pass # Replace with function body.
