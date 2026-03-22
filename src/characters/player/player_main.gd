class_name Player
extends Node3D

@export_category("MODULES")
@export var player_physics: PlayerPhysics
@export var player_camera: PlayerCamera
@export var player_gravity_controller: GravityController
@export_category("VARIABLES")
@export var rotation_speed: float = 1.0
@export var gravity_rotation_speed_modifier: float = 5.0
@export var ground_normal_sensitivity: float = 0.0001

var ground_normal: Vector3 = Vector3.UP
var new_ground_normal: Vector3 = Vector3.UP
var front: Vector3 = Vector3.FORWARD
var is_rotating: bool = false


func _process(delta: float) -> void:
	##new rotation
	_check_new_rotation(delta)
	_update_to_new_rotation(delta)


func _on_player_camera_camera_rotated(_vector: Vector3, angle: float) -> void:
	front = front.rotated(ground_normal, angle)
	player_physics.player_model.rotate(Vector3.UP, angle)
	player_gravity_controller.rotate(Vector3.UP, angle)


## set new rotation values
func _check_new_rotation(_delta: float) -> void:
	if not is_rotating:
		var getting_on_wall: bool = false
		for direction in ["ui_up", "ui_down", "ui_right", "ui_left"]:
			if (
				Input.is_action_pressed(direction) and
				player_gravity_controller.get_sensor_normal(direction) != null
			):
				new_ground_normal = player_gravity_controller.get_sensor_normal(direction)
				getting_on_wall = true
				break
			elif (
				not player_physics.is_on_floor() and
				player_gravity_controller.get_sensor_normal("falling_"+direction) != null and
				player_gravity_controller.get_sensor_normal("floor") == null
			):
				new_ground_normal = player_gravity_controller.get_sensor_normal("falling_"+direction)
				getting_on_wall = true
				break
		if getting_on_wall:
			player_gravity_controller.gravity_no_floor_timer.stop()
		elif player_gravity_controller.get_sensor_normal("floor") != null:
			player_gravity_controller.gravity_no_floor_timer.stop()
			new_ground_normal = player_gravity_controller.get_sensor_normal("floor")
		elif player_gravity_controller.gravity_no_floor_timer.is_stopped():
			player_gravity_controller.gravity_no_floor_timer.start()

func _on_gravity_no_floor_timer_timeout() -> void:
	new_ground_normal = Vector3.UP


## update rotation values
func _update_to_new_rotation(delta: float) -> void:
	if (
		abs(ground_normal.angle_to(new_ground_normal)) > ground_normal_sensitivity
	):
		is_rotating = true
		var moved_ground_normal := (
			ground_normal
			.move_toward(
				new_ground_normal, delta * gravity_rotation_speed_modifier * rotation_speed
			)
			.normalized()
		)
		var angle: float
		if ground_normal == moved_ground_normal:
			angle = ground_normal.angle_to(
				ground_normal.move_toward(
					front,
					delta * gravity_rotation_speed_modifier * rotation_speed
				)
			)
			front = front.rotated(ground_normal.cross(front).normalized(), angle)
			ground_normal = ground_normal.rotated(ground_normal.cross(front).normalized(), angle)
		else:
			angle = ground_normal.angle_to(moved_ground_normal)
			front = front.rotated(ground_normal.cross(moved_ground_normal).normalized(), angle)
			ground_normal = moved_ground_normal
		player_physics.up_direction = ground_normal
		_rotate_player()
	else:
		is_rotating = false


##
func _rotate_player() -> void:
	var tmp_transform := player_physics.global_transform
	tmp_transform.basis.y = ground_normal
	tmp_transform.basis.x = -tmp_transform.basis.z.cross(ground_normal)
	tmp_transform.basis = tmp_transform.basis.orthonormalized()
	player_physics.global_transform = tmp_transform
