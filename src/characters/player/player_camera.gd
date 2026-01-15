extends Node3D

class_name PlayerCamera

signal camera_rotated(vector: Vector3, angle: float)

@export_category("camera locations")
@export var camera: Camera3D
@export var arm: SpringArm3D
@export_category("variables")
@export var maxArmLength: float 				= 12.0
@export var minArmLength: float 				= 2.0
@export var personChangeSpeed: float 			= 2.5
@export var rotationSpeedQE: float 				= 3.0
@export var rotationSpeedMouseHiden: float 		= 0.004
@export var zoomSpeed: float 					= 100.0
@export var defaultCameraRotation: Vector3		= Vector3(0, 0, 0)
@export var cameraUpRotationLimit: float		= 90
@export var cameraDownRotationLimit: float		= -40

enum ROTATION_TYPE{
	QE_KEYBOARD,
	HIDEN_MOUSE
}

var is_3rd_person: bool = true
var rotationType: ROTATION_TYPE = ROTATION_TYPE.QE_KEYBOARD
var armLength: float = 0.0
var person3_arm_length: float = 0.0

func  _ready() -> void:
	rotationType = ROTATION_TYPE.HIDEN_MOUSE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	person3_arm_length = (maxArmLength + minArmLength)/2
	armLength = person3_arm_length
	arm.spring_length = armLength

func _process(delta: float) -> void:
	self.global_position = get_parent().playerPhysics.global_position
	_process_change_person(delta)
	camera.rotation.y = 0
	camera.rotation.z = 0
	
	## CAMERA ROTATION
	if get_parent().isRotating == false:
		if rotationType == ROTATION_TYPE.QE_KEYBOARD:
			if Input.is_action_pressed("ROTATE_CLOCK"):
				rotate_left_right(_get_normal(), rotationSpeedQE*delta)
			if Input.is_action_pressed("ROTATE_COUNTER_CLOCK"):
				rotate_left_right(_get_normal(), -rotationSpeedQE*delta)
	
	## CAMERA ZOOM
	if is_3rd_person:
		if Input.is_action_just_pressed("ZOOM_IN_CAMERA"):
			armLength -= delta * zoomSpeed
			if armLength <= minArmLength:
				armLength = minArmLength
		if Input.is_action_just_pressed("ZOOM_OUT_CAMERA"):
			armLength += delta * zoomSpeed
			if armLength >= maxArmLength:
				armLength = maxArmLength
	

func _process_change_person(delta: float) -> void:
	arm.spring_length = lerp(arm.spring_length, armLength, personChangeSpeed * delta)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("CHANGE_CAMERA"):
		is_3rd_person = not is_3rd_person
		if is_3rd_person:
			rotationType = ROTATION_TYPE.HIDEN_MOUSE
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			armLength = person3_arm_length
			camera.rotation_degrees = defaultCameraRotation
		else:
			rotationType = ROTATION_TYPE.HIDEN_MOUSE
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			person3_arm_length = armLength
			armLength = 0.0
	
	## CAMERA ROTATION
	elif get_parent().isRotating == false:
		if rotationType == ROTATION_TYPE.HIDEN_MOUSE:
			if event is InputEventMouseMotion:
				rotate_left_right(_get_normal(), -event.relative.x * rotationSpeedMouseHiden)
				if not is_3rd_person:
					rotate_up_down(-event.relative.y * rotationSpeedMouseHiden)





func rotate_left_right(vector: Vector3, angle: float) -> void:
	self.rotate(vector, angle)
	camera_rotated.emit(vector, angle)

func rotate_up_down(angle: float) -> void:
	camera.rotate(Vector3.RIGHT, angle)
	if camera.rotation.x > deg_to_rad(cameraUpRotationLimit):
		camera.rotation.x = deg_to_rad(cameraUpRotationLimit)
	elif camera.rotation.x < deg_to_rad(cameraDownRotationLimit):
		camera.rotation.x = deg_to_rad(cameraDownRotationLimit)

func _get_normal() -> Vector3:
	return get_parent().groundNormal
