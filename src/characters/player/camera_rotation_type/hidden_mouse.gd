extends Node

@export var next_strategy: Node
@export var rotation_speed: float = 0.004

func start() -> void:
	change_to()

func rotate(camera: PlayerCamera, relative: Vector2, _delta: float) -> void:
	camera.rotate_left_right(camera.get_normal(), -relative.x * rotation_speed)
	camera.rotate_up_down(-relative.y * rotation_speed)

func change_to() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
