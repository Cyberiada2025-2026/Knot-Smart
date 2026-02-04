extends CharacterBody3D

class_name PlayerPhysics

@export var speed = 500.0
@export var slowing_speed = 500.0
@export var jump_strength = 9.5
@export var gravity_strength = 19.0

var player: Player


func _ready() -> void:
	player = self.get_parent()


func _physics_process(delta: float) -> void:
	_handle_movement(delta)


func _handle_movement(delta: float) -> void:
	_convert_to_flat()
	_handle_flat_movement(delta)
	_convert_to_real()
	move_and_slide()


func _convert_to_flat() -> void:
	var right: Vector3 = player.front.rotated(player.ground_normal, PI / 2)
	var real_velocity = velocity
	velocity.x = real_velocity.dot(right)
	velocity.y = real_velocity.dot(player.ground_normal)
	velocity.z = real_velocity.dot(player.front)


func _convert_to_real() -> void:
	var right: Vector3 = player.front.rotated(player.ground_normal, PI / 2)
	var flat_velocity = velocity
	velocity = (
		(flat_velocity.x * right)
		+ (flat_velocity.y * player.ground_normal)
		+ (flat_velocity.z * player.front)
	)


func _handle_flat_movement(delta: float) -> void:
	_handle_gravity(delta)
	_handle_jump()
	_handle_move_input(delta)


func _handle_move_input(delta: float):
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if input_dir:
		velocity.x = -input_dir.x * speed * delta
		velocity.z = -input_dir.y * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, slowing_speed * delta)
		velocity.z = move_toward(velocity.z, 0, slowing_speed * delta)


func _handle_jump():
	if Input.is_action_just_pressed("jump_button") and is_on_floor():
		velocity.y = jump_strength


func _handle_gravity(delta: float):
	if not is_on_floor():
		velocity += Vector3.DOWN * gravity_strength * delta
