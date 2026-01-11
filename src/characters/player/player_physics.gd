extends CharacterBody3D

class_name PlayerPhysics

@export var SPEED = 500.0
@export var SLOWING_SPEED = 500.0
@export var JUMP_STRENGTH = 9.5
@export var GRAVITY_STRENGTH = 19.0

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
	var right: Vector3 = player.front.rotated(player.groundNormal, PI/2)
	var realVelocity = velocity
	velocity.x = realVelocity.dot(right)
	velocity.y = realVelocity.dot(player.groundNormal)
	velocity.z = realVelocity.dot(player.front)

func _convert_to_real() -> void:
	var right: Vector3 = player.front.rotated(player.groundNormal, PI/2)
	var flatVelocity = velocity
	velocity = (flatVelocity.x * right) + (flatVelocity.y * player.groundNormal) + (flatVelocity.z * player.front)

func _handle_flat_movement(delta: float) -> void:
	_handle_gravity(delta)
	_handle_jump()
	_handle_move_input(delta)

func _handle_move_input(delta: float):
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	if input_dir:
		velocity.x = -input_dir.x * SPEED * delta
		velocity.z = -input_dir.y * SPEED * delta
	else:
		velocity.x = move_toward(velocity.x, 0, SLOWING_SPEED*delta)
		velocity.z = move_toward(velocity.z, 0, SLOWING_SPEED*delta)

func _handle_jump():
	if Input.is_action_just_pressed("JUMP_BUTTON") and is_on_floor():
		velocity.y = JUMP_STRENGTH

func _handle_gravity(delta: float):
	if not is_on_floor():
		velocity += Vector3.DOWN * GRAVITY_STRENGTH * delta
