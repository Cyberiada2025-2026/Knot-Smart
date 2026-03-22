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
func _check_new_rotation(delta: float) -> void:
	if not is_rotating:
		if Input.is_action_pressed("ui_up") and player_gravity_controller.get_front_normal() != null:
			player_gravity_controller.reset_gravity_no_floor_timer()
			new_ground_normal = player_gravity_controller.get_front_normal()
		elif Input.is_action_pressed("ui_down") and player_gravity_controller.get_back_normal() != null:
			player_gravity_controller.reset_gravity_no_floor_timer()
			new_ground_normal = player_gravity_controller.get_back_normal()
		elif Input.is_action_pressed("ui_right") and player_gravity_controller.get_right_normal() != null:
			player_gravity_controller.reset_gravity_no_floor_timer()
			new_ground_normal = player_gravity_controller.get_right_normal()
		elif Input.is_action_pressed("ui_left") and player_gravity_controller.get_left_normal() != null:
			player_gravity_controller.reset_gravity_no_floor_timer()
			new_ground_normal = player_gravity_controller.get_left_normal()
		elif player_physics.is_on_floor() and player_gravity_controller.get_floor_normal() != null:
			player_gravity_controller.reset_gravity_no_floor_timer()
			new_ground_normal = player_gravity_controller.get_floor_normal()
		elif player_gravity_controller.gravity_no_floor_timer_is_stopped():
			player_gravity_controller.start_gravity_no_floor_timer()

func _on_gravity_controller_gravity_no_floor_timer_timeout() -> void:
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
			angle = delta * gravity_rotation_speed_modifier * rotation_speed * 10
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
