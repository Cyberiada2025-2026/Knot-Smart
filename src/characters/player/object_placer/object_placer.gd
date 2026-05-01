class_name ObjectPlacer
extends Node3D

## Returns placed object [br]
## Object is Placer's child, all position transforms were applied [br]
## Use reparent to change object's parent if needed (recommended)
signal placement_finished(placed_object: Node3D)

enum State { IDLE, SELECTING_POSITION }

## maximun radius around player where placement is allowed
@export var placement_range: float = 3
## maximum surface angle in degrees which allows teleporter placement
@export var max_placement_angle = 20
## rotation speed in degrees per second
@export var rotation_speed: int = 90

var _state = State.IDLE

var _marker_rotation
var _prev_mouse_mode
var _prev_camera_mode
var _camera: PlayerCamera

var _item_to_be_placed

@onready var _marker: Marker = $Marker
@onready var _camera_mode = $CameraMode

## enter item placement mode [BR]
## marker is resized automatically based on provided sprite size [BR]
## returns false if enabling placement mode was impossible
func start_placing_next(item: PackedScene, size: Vector3 = Vector3.ZERO) -> bool:
	if _state != State.IDLE:
		print("PLACER: previous placement terminated")
	if size != Vector3.ZERO:
		_marker.resize(size)

	if not _camera:
		_camera = get_node("../PlayerPhysics/PlayerCamera")

	if _camera.get_view_type() != PlayerCamera.ViewType.THIRD_PERSON:
		return false

	if _state != State.SELECTING_POSITION:
		_prev_mouse_mode = Input.get_mouse_mode()
		_prev_camera_mode = _camera.rotation_strategy
		_camera.rotation_strategy = _camera_mode
		_camera.rotation_strategy.next_strategy = _prev_camera_mode
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_state = State.SELECTING_POSITION

	_marker.collision_shape.disabled = false
	_marker_rotation = 0

	_item_to_be_placed = item
	return true


func exit_placement_mode():
	_set_idle()


func _set_idle():
	Input.set_mouse_mode(_prev_mouse_mode)
	_camera.rotation_strategy = _prev_camera_mode
	_state = State.IDLE
	_marker.collision_shape.disabled = true


func _physics_process(delta: float) -> void:
	_marker.hide()

	if _state != State.SELECTING_POSITION:
		return

	if (
		_camera.get_view_type() != PlayerCamera.ViewType.THIRD_PERSON
		or Input.is_action_just_pressed("pause_button")
		or _camera.rotation_strategy != _camera_mode
	):
		_set_idle()
		return

	var raycast_result = (
		UnsafeRaycastBuilder.new(self)
			.set_screen_position(get_viewport().get_mouse_position())
			.raycast()
	)

	if raycast_result.is_empty():
		return

	var player_position = get_node("../").player_physics.position

	if _v3_to_v2(player_position).distance_to(_v3_to_v2(raycast_result.position)) > placement_range:
		raycast_result.position = (
			(raycast_result.position - player_position).normalized() * placement_range
			+ player_position
		)
		raycast_result.position.y = player_position.y

		var roof = (
			UnsafeRaycastBuilder.new(self)
				.set_ray_length(50)
				.set_raycast_origin(raycast_result.position)
				.set_direction(Vector3.UP)
				.set_collision_mask(1)
				.raycast()
		)

		var raycast_origin = raycast_result.position + Vector3(0, 50, 0)

		if not roof.is_empty():
			raycast_origin.y = roof.position.y

		raycast_result = (
			UnsafeRaycastBuilder.new(self)
				.set_ray_length(100)
				.set_raycast_origin(raycast_origin)
				.set_direction(Vector3.DOWN)
				.raycast()
		)
		if raycast_result.is_empty():
			return

	# avoiding too big terrain angles
	var hit_normal = raycast_result.normal
	var slope_angle_rad = hit_normal.angle_to(Vector3.UP)
	if rad_to_deg(slope_angle_rad) > max_placement_angle:
		return

	# fix box height to avoid being in textures
	raycast_result.position += _marker.get_half_height() * raycast_result.normal

	_marker.quaternion = Quaternion(Vector3.UP, raycast_result.normal)
	_marker.global_position = raycast_result.position
	# fix collision with floor due to low float precision
	_marker.global_position += Vector3(0, 0.000001, 0)


	if Input.is_action_pressed("rotate"):
		_marker_rotation = _marker_rotation + rotation_speed * delta
	if _marker_rotation > 360:
		_marker_rotation -= 360

	_marker.rotate_object_local(Vector3.UP, deg_to_rad(_marker_rotation))

	_marker.update_state()

	_marker.show()

	if Input.is_action_just_pressed("left_mouse") and _marker.allows_placement:
		_place()


func _place():
	# sometimes marker is still visible when something handles placement_finished signal
	_marker.hide()

	var placed_item = _item_to_be_placed.instantiate()
	add_child(placed_item)
	placed_item.global_position = _marker.global_position
	placed_item.quaternion = _marker.quaternion
	_set_idle()

	placement_finished.emit(placed_item)


func _v3_to_v2(vector: Vector3) -> Vector2:
	return Vector2(vector.x, vector.z)
