extends CanvasItem

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_crt"):
		visible = !visible
