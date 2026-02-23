extends Node

@export var next_strategy: Node
@export var should_rotate_left_right: bool = true
@export var should_rotate_up_down: bool = false
@export var max_arm_length: float = 12.0
@export var default_arm_length: float = 7.0
@export var min_arm_length: float = 2.0
@export var zoom_speed: float = 100.0
@export var default_camera_rotation: Vector3 = Vector3(0, 0, 0)


func start(camera: PlayerCamera) -> void:
	change_view_to(camera)
	camera.arm.spring_length = default_arm_length


func zoom(camera: PlayerCamera, delta: float) -> void:
	if Input.is_action_just_pressed("zoom_in_camera"):
		camera.arm_length -= delta * zoom_speed
		if camera.arm_length <= min_arm_length:
			camera.arm_length = min_arm_length
	if Input.is_action_just_pressed("zoom_out_camera"):
		camera.arm_length += delta * zoom_speed
		if camera.arm_length >= max_arm_length:
			camera.arm_length = max_arm_length


func change_view_to(camera: PlayerCamera) -> void:
	camera.camera.rotation_degrees = default_camera_rotation
	camera.arm_length = default_arm_length
