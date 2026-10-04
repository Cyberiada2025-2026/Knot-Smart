extends Node

@export var settings_menu: Control


var prev_mouse_mode: Input.MouseMode


func unpause_game() -> void:
	if settings_menu.visible:
		return
	get_tree().paused = false
	get_child(0).hide()
	Input.set_mouse_mode(prev_mouse_mode)


func pause_game() -> void:
	get_tree().paused = true
	get_child(0).show()
	prev_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unhandled_input(event):
	var unpausable = get_tree().get_nodes_in_group("unpausable")

	for node in unpausable:
		if node.visible:
			return

	if event is InputEventKey and event.is_action("pause_button") and event.is_pressed():
		if get_tree().paused == false:
			pause_game()
		else:
			unpause_game()
		get_viewport().set_input_as_handled()


func _on_return_button_pressed() -> void:
	unpause_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed():
	settings_menu.show()
