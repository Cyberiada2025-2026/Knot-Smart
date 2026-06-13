extends Node

@export var next_strategy: Node
@export var camera_up_rotation_limit: float = 90
@export var camera_down_rotation_limit: float = -40
@export var camera_position: Vector3 = Vector3(0.3, 0.28, 0.0)
@export var arm_length = 0.5


func start(camera: PlayerCamera) -> void:
	change_view_to(camera)
	camera.arm.spring_length = 0.0


func change_view_to(camera: PlayerCamera) -> void:
	camera.arm_length = arm_length
	camera.arm_position = camera_position


func zoom(_camera: PlayerCamera, _delta: float) -> void:
	pass


func get_view_type() -> PlayerCamera.ViewType:
	return PlayerCamera.ViewType.FIRST_PERSON
