extends Node

var prev_mouse_mode


func unpause_game() -> void:
	PauseController.unpause_game()
	get_child(0).hide()


func pause_game() -> void:
	PauseController.pause_game()
	get_child(0).show()


func _process(_delta: float) -> void:
	var unpausable = get_tree().get_nodes_in_group("unpausable")

	for node in unpausable:
		if node.visible:
			return

	if Input.is_action_just_pressed("pause_button"):
		if get_tree().paused == false:
			pause_game()
		else:
			unpause_game()


func _on_return_button_pressed() -> void:
	unpause_game()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
