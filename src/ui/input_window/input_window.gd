class_name InputWindow
extends Node

signal _text_submitted()

@onready var submit_field: LineEdit = $Control/VBoxContainer/LineEdit
@onready var submit_button: Button  = $Control/VBoxContainer/SubmitButton
@onready var label: RichTextLabel = $Control/VBoxContainer/RichTextLabel

func unpause_game() -> void:
	PauseController.unpause_game()
	get_child(0).hide()


func pause_game() -> void:
	PauseController.pause_game()
	get_child(0).show()


# _text is used to properly handle lext_submitted signal from LineEdit without errors
func _submitted(_text = ""):
	_text_submitted.emit()


## async function to get input text from keyboard [br]
## message is limited by textbox size and may not be shown fully
func get_input(message: String = "") -> String:
	pause_game()
	submit_field.grab_focus()

	submit_field.text = ""
	label.text = message

	while true:
		await _text_submitted
		if not submit_field.text.is_empty():
			break

	unpause_game()
	return submit_field.text
