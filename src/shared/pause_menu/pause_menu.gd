extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func button_pressed() -> void:
	if Input.is_action_just_pressed("pause_button"):
		print("pause")
		if (is_inside_tree()):
			get_tree().paused = not get_tree().paused
			get_child(0).visible = not get_child(0).visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var not_pausable = get_tree().get_nodes_in_group("not_pausable")
	
	if not not_pausable.is_empty():
		for i in range(not_pausable.size()):
			if not_pausable[i].visible == false:
				button_pressed()
	else:
		button_pressed()
	

func _on_button_pressed() -> void:
	print("click")
	get_tree().paused = false
	get_child(0).hide()
