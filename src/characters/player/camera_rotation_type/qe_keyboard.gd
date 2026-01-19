extends Node


@export var rotation_speed: float = 3.0

func start() -> void:
	change_to()

func rotate(camera: PlayerCamera, _relative: Vector2, delta: float) -> void:
	if Input.is_action_pressed("rotate_counter_clock"):
		camera.rotate_left_right(camera.get_normal(), rotation_speed*delta)
	if Input.is_action_pressed("rotate_clock"):
		camera.rotate_left_right(camera.get_normal(), -rotation_speed*delta)

func change_to() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
