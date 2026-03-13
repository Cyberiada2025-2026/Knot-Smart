extends Node

var prev_mouse_mode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func unpause_game() -> void:
	get_tree().paused = false
	get_child(0).hide()
	Input.set_mouse_mode(prev_mouse_mode)


func pause_game() -> void:
	get_tree().paused = true
	get_child(0).show()
	prev_mouse_mode = Input.get_mouse_mode()
	Input.set_mouse_mode(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var not_pausable = get_tree().get_nodes_in_group("not_pausable")

	if not not_pausable.is_empty():
		for i in range(not_pausable.size()):
			if not_pausable[i].visible == true:
				return

	if Input.is_action_just_pressed("pause_button"):
		print("pause")

		if is_inside_tree():
			if get_tree().paused == false:
				pause_game()
			else:
				unpause_game()


func _on_button_pressed() -> void:
	unpause_game()
