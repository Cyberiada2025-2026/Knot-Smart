extends Node


@export var next_strategy: Node
@export var should_rotate_left_right: bool = true
@export var should_rotate_up_down: bool = true


func start(camera: PlayerCamera) -> void:
	change_view_to(camera)
	camera.arm.spring_length = 0.0

func change_view_to(camera: PlayerCamera) -> void:
	camera.arm_length = 0.0

func zoom(_camera: PlayerCamera, _delta: float) -> void:
	pass
