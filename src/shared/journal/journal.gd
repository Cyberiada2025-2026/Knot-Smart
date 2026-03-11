## Manages the journal system
extends Node

var is_visible = false
var button1: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button1 = get_child(0)
	button1.set_visible(false)
	pass # Replace with function body.

func _init() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("journal_show"):
		print("click1")
		if button1.visible == true:
			button1.visible = false
		else:
			button1.visible = true
	
	pass
	
func _physics_process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	print("click2")
	pass # Replace with function body.
