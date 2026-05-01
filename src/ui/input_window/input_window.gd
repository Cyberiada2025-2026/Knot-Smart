class_name InputWindow
extends Node


@export var submit_button_pressed: Signal
var submitted: bool = false

@onready var submit_field: LineEdit = $Control/VBoxContainer/LineEdit
@onready var submit_button: Button  = $Control/VBoxContainer/SubmitButton
@onready var label: RichTextLabel = $Control/VBoxContainer/RichTextLabel

func unpause_game() -> void:
	PauseController.unpause_game()
	get_child(0).hide()


func pause_game() -> void:
	PauseController.pause_game()
	get_child(0).show()


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
