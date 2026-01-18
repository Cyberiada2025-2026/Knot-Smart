extends Node3D

class_name Player

@export_category("MODULES")
@export var player_physics: PlayerPhysics
@export var player_camera: PlayerCamera
@export var player_floor_sensor: RayCast3D
@export_category("VARIABLES")
@export var rotation_speed: float = 1.0
@export var gravity_rotation_speed_modifier: float = 5.0
@export var gravity_reset_time: float = 1.0
@export var ground_normal_sensitivity: float = 0.0001

var ground_normal: Vector3 = Vector3.UP
var new_ground_normal: Vector3 = Vector3.UP
var front: Vector3 = Vector3.FORWARD
var gravity_reset_timer: float = 0.0
var is_rotating: bool = false


func _process(delta: float) -> void:
	##new rotation
	_check_new_rotation(delta)
	_update_to_new_rotation(delta)
	
	



func _on_player_camera_camera_rotated(_vector: Vector3, angle: float) -> void:
	front = front.rotated(ground_normal, angle)




## set new rotation values
func _check_new_rotation(delta: float) -> void:
	if player_physics.is_on_floor():
		gravity_reset_timer = 0.0
		new_ground_normal = player_floor_sensor.get_collision_normal()
	else:
		gravity_reset_timer += delta
	
	if gravity_reset_timer >= gravity_reset_time:
		new_ground_normal = Vector3.UP

## update rotation values
func _update_to_new_rotation(delta: float) -> void:
	if abs(ground_normal - new_ground_normal) > Vector3(ground_normal_sensitivity, ground_normal_sensitivity, ground_normal_sensitivity):
		is_rotating = true
		var moved_ground_normal := ground_normal.move_toward(new_ground_normal, delta * gravity_rotation_speed_modifier * rotation_speed).normalized()
		var angle := ground_normal.angle_to(moved_ground_normal)
		player_camera.rotate(ground_normal.cross(moved_ground_normal).normalized(), angle)
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
