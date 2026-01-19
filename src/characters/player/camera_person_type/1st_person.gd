extends ViewTypeBase


func start(camera: PlayerCamera) -> void:
	camera.arm_length = 0
	camera.arm.spring_length = 0

func change_view_to(camera: PlayerCamera, _event: InputEvent) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.arm_length = 0.0
