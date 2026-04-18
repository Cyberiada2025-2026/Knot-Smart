extends Node


@export var submit_button_pressed: Signal
var submitted: bool = false

var prev_mouse_mode
@onready var submit_field: TextEdit = $Control/VBoxContainer/TextEdit

func unpause_game() -> void:
	get_tree().paused = false
	get_child(0).hide()
	Input.set_mouse_mode(prev_mouse_mode)


func pause_game() -> void:
	get_tree().paused = true
	get_child(0).show()
	prev_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## async function to get input text from keyboard!!!
func get_input() -> String:
	pause_game()

	#get_tree().create_timer(2.0).timeout.connect(func(): submit_button_pressed.emit())
	unpause_game()
	return submit_field.text


func _on_submit_button_button_down() -> void:
	pass # Replace with function body.
