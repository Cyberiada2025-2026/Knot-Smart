class_name Player
extends CharacterBody3D

enum {IDLE, WALK, JUMP}

@export_category("MODULES")
@export var player_model: Node3D
@export var player_camera: PlayerCamera
@export var player_gravity_controller: GravityController
@export_category("PlayerProperties")
@export var speed = 500.0
@export var slowing_speed = 500.0
@export var jump_strength = 9.5
@export var gravity_strength = 19.0
@export var blend_anim_speed = 0.5

var animation_tree: AnimationTree
var walk_blend = 0.0
var is_shooting = false


func _ready() -> void:
	animation_tree = player_model.find_child("AnimationTree", false)


func _on_player_camera_camera_rotated(_vector: Vector3, angle: float) -> void:
	player_gravity_controller.front = get_front().rotated(get_normal(), angle)
	player_model.rotate(Vector3.UP, angle)
	player_gravity_controller.rotate(Vector3.UP, angle)


##
func _rotate_player() -> void:
	var tmp_transform := global_transform
	tmp_transform.basis.y = get_normal()
	tmp_transform.basis.x = -tmp_transform.basis.z.cross(get_normal())
	tmp_transform.basis = tmp_transform.basis.orthonormalized()
	global_transform = tmp_transform


func get_normal() -> Vector3:
	return player_gravity_controller.ground_normal


func get_front() -> Vector3:
	return player_gravity_controller.front


func get_is_rotating() -> bool:
	return player_gravity_controller.is_rotating


func _physics_process(delta: float) -> void:
	_convert_to_flat()
	_handle_flat_movement(delta)
	_convert_to_real()
	move_and_slide()


func _convert_to_flat() -> void:
	var right: Vector3 = get_front().rotated(get_normal(), PI / 2)
	var real_velocity = velocity
	velocity.x = real_velocity.dot(right)
	velocity.y = real_velocity.dot(get_normal())
	velocity.z = real_velocity.dot(get_front())


func _convert_to_real() -> void:
	var right: Vector3 = get_front().rotated(get_normal(), PI / 2)
	var flat_velocity = velocity
	velocity = (
		(flat_velocity.x * right)
		+ (flat_velocity.y * get_normal())
		+ (flat_velocity.z * get_front())
	)


func _handle_flat_movement(delta: float) -> void:
	_handle_gravity(delta)
	_handle_jump()
	_handle_move_input(delta)


func _handle_move_input(delta: float):
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if input_dir:
		if is_on_floor_check():
			animation_tree.set("parameters/Movement/transition_request", "Walk")
		velocity.x = -input_dir.x * speed * delta
		velocity.z = -input_dir.y * speed * delta
	else:
		if is_on_floor_check() and not is_shooting:
			animation_tree.set("parameters/Movement/transition_request", "Idle")
		if is_shooting:
			animation_tree.set("parameters/Movement/transition_request", "Shoot")
		velocity.x = move_toward(velocity.x, 0, slowing_speed * delta)
		velocity.z = move_toward(velocity.z, 0, slowing_speed * delta)


func _handle_jump():
	if Input.is_action_just_pressed("jump_button") and is_on_floor_check():
		velocity.y = jump_strength


func _on_player_camera_view_changed() -> void:
	is_shooting = !is_shooting


func _handle_gravity(delta: float):
	if not is_on_floor_check():
		animation_tree.set("parameters/Movement/transition_request", "Jump")
		velocity += Vector3.DOWN * gravity_strength * delta


func is_on_floor_check():
	if is_on_floor():
		return true
	$RayCast3D.force_raycast_update()
	if $RayCast3D.is_colliding():
		return true
