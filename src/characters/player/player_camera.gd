class_name PlayerCamera
extends Node3D

signal camera_rotated(vector: Vector3, angle: float)

@export_category("camera locations")
@export var camera: Node3D
@export var arm: SpringArm3D
@export_category("variables")
@export var person_change_speed: float = 2.5
@export var camera_up_rotation_limit: float = 90
@export var camera_down_rotation_limit: float = -40
@export_category("dafault strategies")
@export_subgroup("rotation")
@export var rotation_strategy: Node
@export_subgroup("view")
@export var view_strategy: Node
@export_category("strategies nodes")
@export_subgroup("rotation")
@export var qe_keyboard: Node
@export var hidden_mouse: Node
@export_subgroup("view")
@export var first_person_camera: Node
@export var third_person_camera: Node

var arm_length: float
var mouse_relative: Vector2 = Vector2.ZERO


func _ready() -> void:
	CameraSingleton.get_instance().reference = camera
	rotation_strategy.start()
	view_strategy.start(self)


func _process(delta: float) -> void:
	self.global_position = get_parent().player_physics.global_position
	_process_change_person(delta)
	camera.rotation.y = 0
	camera.rotation.z = 0

	## CAMERA ROTATION
	if get_parent().is_rotating == false:
		rotation_strategy.rotate(self, mouse_relative, delta)
	mouse_relative = Vector2.ZERO

	## CAMERA ZOOM
	view_strategy.zoom(self, delta)


func _process_change_person(delta: float) -> void:
	arm.spring_length = lerp(arm.spring_length, arm_length, person_change_speed * delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("change_camera"):
		view_strategy = view_strategy.next_strategy
		view_strategy.change_view_to(self)

	if event.is_action_pressed("change_camera_mode"):
		rotation_strategy = rotation_strategy.next_strategy
		rotation_strategy.change_to()

	## CAMERA ROTATION
	if event is InputEventMouseMotion:
		mouse_relative += event.relative


func rotate_left_right(vector: Vector3, angle: float) -> void:
	if view_strategy.should_rotate_left_right:
		self.rotate(vector, angle)
		camera_rotated.emit(vector, angle)


func rotate_up_down(angle: float) -> void:
	if view_strategy.should_rotate_up_down:
		camera.rotate(Vector3.RIGHT, angle)
		if camera.rotation.x > deg_to_rad(camera_up_rotation_limit):
			camera.rotation.x = deg_to_rad(camera_up_rotation_limit)
		elif camera.rotation.x < deg_to_rad(camera_down_rotation_limit):
			camera.rotation.x = deg_to_rad(camera_down_rotation_limit)


func get_normal() -> Vector3:
	return get_parent().ground_normal
