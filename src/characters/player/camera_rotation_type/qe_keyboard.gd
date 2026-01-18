extends BaseCameraRotationType


@export var rotation_speed: float = 3.0


func rotate_with_keyboard(camera: PlayerCamera, delta: float) -> void:
	if Input.is_action_pressed("ROTATE_CLOCK"):
		camera.rotate_left_right(camera.get_normal(), rotation_speed*delta)
	if Input.is_action_pressed("ROTATE_COUNTER_CLOCK"):
		camera.rotate_left_right(camera.get_normal(), -rotation_speed*delta)
