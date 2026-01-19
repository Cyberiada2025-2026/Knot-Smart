extends Node3D

class_name PlayerCamera

signal camera_rotated(vector: Vector3, angle: float)

enum RotationType{
	QE_KEYBOARD,
	HIDDEN_MOUSE
}

@export_category("camera locations")
@export var camera: Camera3D
@export var arm: SpringArm3D
@export_category("variables")
@export var max_arm_length: float = 12.0
@export var min_arm_length: float = 2.0
@export var person_change_speed: float = 2.5
@export var zoom_speed: float = 100.0
@export var default_camera_rotation: Vector3 = Vector3(0, 0, 0)
@export var camera_up_rotation_limit: float = 90
@export var camera_down_rotation_limit: float = -40
@export_category("subscripts")
@export var rotation_strategy: Dictionary[RotationType, BaseCameraRotationType]

var is_3rd_person: bool = true
var arm_length: float = 0.0
var person3_arm_length: float = 0.0
var rotation_type: RotationType = RotationType.QE_KEYBOARD


func  _ready() -> void:
	rotation_type = RotationType.HIDDEN_MOUSE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	person3_arm_length = (max_arm_length + min_arm_length)/2
	arm_length = person3_arm_length
	arm.spring_length = arm_length

func _process(delta: float) -> void:
	self.global_position = get_parent().player_physics.global_position
	_process_change_person(delta)
	camera.rotation.y = 0
	camera.rotation.z = 0
	
	## CAMERA ROTATION
	if get_parent().is_rotating == false:
		rotation_strategy[rotation_type].rotate_with_keyboard(self, delta)
	
	## CAMERA ZOOM
	if is_3rd_person:
		if Input.is_action_just_pressed("zoom_in_camera"):
			arm_length -= delta * zoom_speed
			if arm_length <= min_arm_length:
				arm_length = min_arm_length
		if Input.is_action_just_pressed("zoom_out_camera"):
			arm_length += delta * zoom_speed
			if arm_length >= max_arm_length:
				arm_length = max_arm_length
	

func _process_change_person(delta: float) -> void:
	arm.spring_length = lerp(arm.spring_length, arm_length, person_change_speed * delta)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("change_camera"):
		is_3rd_person = not is_3rd_person
		if is_3rd_person:
			rotation_type = RotationType.HIDDEN_MOUSE
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			arm_length = person3_arm_length
			camera.rotation_degrees = default_camera_rotation
		else:
			rotation_type = RotationType.HIDDEN_MOUSE
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			person3_arm_length = arm_length
			arm_length = 0.0
	
	## CAMERA ROTATION
	elif get_parent().is_rotating == false:
		rotation_strategy[rotation_type].rotate_with_mouse(self, event)





func rotate_left_right(vector: Vector3, angle: float) -> void:
	self.rotate(vector, angle)
	camera_rotated.emit(vector, angle)

func rotate_up_down(angle: float) -> void:
	camera.rotate(Vector3.RIGHT, angle)
	if camera.rotation.x > deg_to_rad(camera_up_rotation_limit):
		camera.rotation.x = deg_to_rad(camera_up_rotation_limit)
	elif camera.rotation.x < deg_to_rad(camera_down_rotation_limit):
		camera.rotation.x = deg_to_rad(camera_down_rotation_limit)

func get_normal() -> Vector3:
	return get_parent().ground_normal
