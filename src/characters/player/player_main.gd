class_name Player
extends Node3D

@export_category("MODULES")
@export var player_physics: PlayerPhysics
@export var player_camera: PlayerCamera
@export var player_gravity_controller: GravityController


func _on_player_camera_camera_rotated(_vector: Vector3, angle: float) -> void:
	player_gravity_controller.front = get_front().rotated(get_normal(), angle)
	player_physics.player_model.rotate(Vector3.UP, angle)
	player_gravity_controller.rotate(Vector3.UP, angle)


##
func _rotate_player() -> void:
	var tmp_transform := player_physics.global_transform
	tmp_transform.basis.y = get_normal()
	tmp_transform.basis.x = -tmp_transform.basis.z.cross(get_normal())
	tmp_transform.basis = tmp_transform.basis.orthonormalized()
	player_physics.global_transform = tmp_transform


func get_normal() -> Vector3:
	return player_gravity_controller.ground_normal


func get_front() -> Vector3:
	return player_gravity_controller.front


func get_is_rotating() -> bool:
	return player_gravity_controller.is_rotating
