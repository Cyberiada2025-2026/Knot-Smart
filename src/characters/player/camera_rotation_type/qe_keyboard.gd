extends BaseCameraRotationType


@export var rotation_speed: float = 3.0


func rotate_with_keyboard(camera: PlayerCamera, delta: float) -> void:
	if Input.is_action_pressed("rotate_clock"):
		camera.rotate_left_right(camera.get_normal(), rotation_speed*delta)
	if Input.is_action_pressed("rotate_counter_clock"):
		camera.rotate_left_right(camera.get_normal(), -rotation_speed*delta)
