class_name InputWindow
extends Node


@export var submit_button_pressed: Signal
var submitted: bool = false

var prev_mouse_mode
@onready var submit_field: LineEdit = $Control/VBoxContainer/LineEdit
@onready var submit_button: Button  = $Control/VBoxContainer/SubmitButton
@onready var label: RichTextLabel = $Control/VBoxContainer/RichTextLabel

# try moving to utils
# move to utils!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# failed, try again later
func unpause_game() -> void:
	get_tree().paused = false
	get_child(0).hide()
	Input.set_mouse_mode(prev_mouse_mode)


func pause_game() -> void:
	get_tree().paused = true
	get_child(0).show()
	prev_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## async function to get input text from keyboard [br]
## message is limited by textbox size and may not be shown fully
func get_input(message: String = "") -> String:
	pause_game()

	submit_field.text = ""
	label.text = message

	while true:
		await submit_button.button_down
		if not submit_field.text.is_empty():
			break

	unpause_game()
	return submit_field.text
