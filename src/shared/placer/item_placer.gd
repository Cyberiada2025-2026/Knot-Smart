class_name ItemPlacer
extends Node

enum State { IDLE, SELECTING_POSITION }

## maximun radius around player where placement is allowed
@export var placement_range: float = 3
## maximum surface angle in degrees which allows teleporter placement
@export var max_placement_angle = 20
@export var marker_scene: PackedScene

signal placement_finished(placed_object: Node3D)

var state = State.IDLE
var marker: Marker

var prev_mouse_mode
var prev_camera_mode
var camera: PlayerCamera

var item_to_be_placed

func _ready() -> void:
	marker = marker_scene.instantiate()
	add_child(marker)


## enter item placement mode [BR]
## marker is resized automatically based on provided sprite size [BR]
## returns false if enabling placement mode was impossible
func place(item: Node3D, size: Vector3 = Vector3.ZERO) -> bool:
	if state != State.IDLE:
		printerr("PLACER ERROR: code tried to place next item when previous placement is still active")

	if size != Vector3.ZERO:
		marker.resize(size)

	if not camera:
		camera = get_node("../PlayerPhysics/PlayerCamera")

	if (
		Input.is_action_just_pressed("teleporter_place_mode")
		and camera.get_view_type() == PlayerCamera.ViewType.THIRD_PERSON
	):
		state = State.SELECTING_POSITION
		prev_mouse_mode = Input.get_mouse_mode()
		prev_camera_mode = camera.rotation_strategy
		camera.rotation_strategy = get_node("CameraMode")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		item_to_be_placed = item
		return true

	return false


func exit_placement_mode():
	_set_idle()


func _set_idle():
	Input.set_mouse_mode(prev_mouse_mode)
	camera.rotation_strategy = prev_camera_mode
	state = State.IDLE


func _physics_process(_delta: float) -> void:
	if state != State.SELECTING_POSITION:
		return

	if (
		camera.get_view_type() != PlayerCamera.ViewType.THIRD_PERSON
		#or Input.is_action_just_pressed("teleporter_place_mode")
		or Input.is_action_just_pressed("pause_button")
	):
		_set_idle()
		return
