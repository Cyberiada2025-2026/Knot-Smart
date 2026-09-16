class_name PlayerCamera
extends Node3D

signal camera_rotated(vector: Vector3, angle: float)
signal view_changed

enum ViewType {
	FIRST_PERSON,
	THIRD_PERSON,
}

@export var player: Player
@export_category("camera locations")
@export var camera: Node3D
@export var arm: SpringArm3D
@export_category("variables")
@export var person_change_speed: float = 9.0
@export_category("dafault strategies")
@export_subgroup("rotation")
@export var rotation_strategy: Node
@export_subgroup("view")
@export var view_strategy: Node
@export_category("strategies nodes")
@export_subgroup("rotation")
@export var qe_keyboard: Node
@export var hidden_mouse: Node
@export var rotation_lerp_weight: float = 0.4
@export_subgroup("view")
@export var first_person_camera: Node
@export var third_person_camera: Node

var arm_length: float
var arm_position: Vector3
var prev_arm_length: float
var mouse_relative: Vector2 = Vector2.ZERO


func _ready() -> void:
	get_viewport().get_camera_3d().set_reference(camera)
	rotation_strategy.start()
	view_strategy.start(self)


func _process(delta: float) -> void:
	_process_change_person(delta)
	camera.rotation.y = 0
	camera.rotation.z = 0

	## CAMERA ROTATION
	var lerped_mouse_relative = Vector2(
		lerp(0.0, mouse_relative.x, rotation_lerp_weight),
		lerp(0.0, mouse_relative.y, rotation_lerp_weight)
	)
	rotation_strategy.rotate(self, lerped_mouse_relative, delta)
	mouse_relative -= lerped_mouse_relative

	## CAMERA ZOOM
	view_strategy.zoom(self, delta)


func _process_change_person(delta: float) -> void:
	arm.spring_length = lerp(arm.spring_length, arm_length, person_change_speed * delta)
	arm.position = lerp(arm.position, arm_position, person_change_speed * delta)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera"):
		view_strategy = view_strategy.next_strategy
		view_strategy.change_view_to(self)
		view_changed.emit()

	if event.is_action_pressed("change_camera_mode"):
		rotation_strategy = rotation_strategy.next_strategy
		rotation_strategy.change_to()

	## CAMERA ROTATION
	if event is InputEventMouseMotion:
		mouse_relative += event.relative


func rotate_left_right(vector: Vector3, angle: float) -> void:
	self.rotate(Vector3.UP, angle)
	camera_rotated.emit(vector, angle)


func rotate_up_down(angle: float) -> void:
	arm.rotate(Vector3.RIGHT, angle)

	if arm.rotation.x > deg_to_rad(view_strategy.camera_up_rotation_limit):
		arm.rotation.x = deg_to_rad(view_strategy.camera_up_rotation_limit)
	elif arm.rotation.x < deg_to_rad(view_strategy.camera_down_rotation_limit):
		arm.rotation.x = deg_to_rad(view_strategy.camera_down_rotation_limit)


func get_normal() -> Vector3:
	return player.get_normal()


func get_view_type() -> ViewType:
	return view_strategy.get_view_type()
