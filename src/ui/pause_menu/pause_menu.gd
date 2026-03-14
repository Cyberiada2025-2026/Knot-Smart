extends Node

var prev_mouse_mode


func unpause_game() -> void:
	get_tree().paused = false
	get_child(0).hide()
	Input.set_mouse_mode(prev_mouse_mode)


func pause_game() -> void:
	get_tree().paused = true
	get_child(0).show()
	prev_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(0)


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
