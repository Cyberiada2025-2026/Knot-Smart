extends Node3D

class_name PlayerCamera

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
@export var rotation_strategy: BaseCameraRotationType
@export_subgroup("view")
@export var view_strategy: ViewTypeBase
@export_category("strategies nodes")
@export_subgroup("rotation")
@export var qe_keyboard: BaseCameraRotationType
@export var hidden_mouse: BaseCameraRotationType
@export_subgroup("view")
@export var first_person_camera: ViewTypeBase
@export var third_person_camera: ViewTypeBase

var arm_length: float


func  _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	view_strategy.start(self)

func _process(delta: float) -> void:
	self.global_position = get_parent().player_physics.global_position
	_process_change_person(delta)
	camera.rotation.y = 0
	camera.rotation.z = 0
	
	## CAMERA ROTATION
	if get_parent().is_rotating == false:
		rotation_strategy.rotate_with_keyboard(self, delta)
	
	## CAMERA ZOOM
	view_strategy.zoom(self, delta)

func _process_change_person(delta: float) -> void:
	pass
	arm.spring_length = lerp(arm.spring_length, arm_length, person_change_speed * delta)



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("change_camera"):
		view_strategy = view_strategy.next_strategy
		view_strategy.change_view_to(self, event)
	
	## CAMERA ROTATION
	elif get_parent().is_rotating == false:
		rotation_strategy.rotate_with_mouse(self, event)


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
