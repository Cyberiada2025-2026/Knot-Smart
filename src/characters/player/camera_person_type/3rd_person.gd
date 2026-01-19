extends PersonTypeBase


func zoom(camera: PlayerCamera, delta: float) -> void:
	if Input.is_action_just_pressed("zoom_in_camera"):
		camera.arm_length -= delta * camera.zoom_speed
		if camera.arm_length <= camera.min_arm_length:
			camera.arm_length = camera.min_arm_length
	if Input.is_action_just_pressed("zoom_out_camera"):
		camera.arm_length += delta * camera.zoom_speed
		if camera.arm_length >= camera.max_arm_length:
			camera.arm_length = camera.max_arm_length

func change_camera(camera: PlayerCamera, event: InputEvent) -> void:
	camera.person_type = camera.PersonType.PERSON1
	camera.person_strategy[camera.person_type].change_camera_to(camera, event)


func change_camera_to(camera: PlayerCamera, _event: InputEvent) -> void:
	camera.rotation_type = camera.RotationType.HIDDEN_MOUSE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.arm_length = camera.person3_arm_length
	camera.camera.rotation_degrees = camera.default_camera_rotation
