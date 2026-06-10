extends Node

@export var next_strategy: Node
@export var camera_up_rotation_limit: float = 90
@export var camera_down_rotation_limit: float = -40
@export var camera_height: float = 0.28


func start(camera: PlayerCamera) -> void:
	change_view_to(camera)
	camera.arm.spring_length = 0.0


func change_view_to(camera: PlayerCamera) -> void:
	camera.player.player_physics.player_model.hide()
	camera.arm_length = 0.0
	camera.arm.position.y = camera_height
	camera.arm.position.z = 0.0


func zoom(_camera: PlayerCamera, _delta: float) -> void:
	pass


func get_view_type() -> PlayerCamera.ViewType:
	return PlayerCamera.ViewType.FIRST_PERSON
