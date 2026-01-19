extends PersonTypeBase

func change_camera(camera: PlayerCamera, event: InputEvent) -> void:
	camera.person_type = camera.PersonType.PERSON3
	camera.person_strategy[camera.person_type].change_camera_to(camera, event)

func change_camera_to(camera: PlayerCamera, _event: InputEvent) -> void:
	camera.rotation_type = camera.RotationType.HIDDEN_MOUSE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.person3_arm_length = camera.arm_length
	camera.arm_length = 0.0
