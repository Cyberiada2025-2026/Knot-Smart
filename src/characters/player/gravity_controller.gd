class_name GravityController
extends Node3D

@export var player: Player
@export_category("sensors")
@export var sensors: Dictionary[String, RayCast3D]
@export_category("timers")
@export var gravity_no_floor_timer: Timer
@export_category("VARIABLES")
@export var rotation_speed: float = 1.0
@export var gravity_rotation_speed_modifier: float = 5.0
@export var ground_normal_sensitivity: float = 0.0001


var ground_normal: Vector3 = Vector3.UP
var front: Vector3 = Vector3.FORWARD
var are_sensors_active: bool = true
var is_rotating: bool = false
var new_ground_normal: Vector3 = Vector3.UP


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gravity_controller"):
		are_sensors_active = not are_sensors_active

## return detected floor normal or Vector3.UP if are_sensors_active is false or null otherwise
func get_sensor_normal(sensor: String):
	if not are_sensors_active:
		return Vector3.UP
	if sensors[sensor].is_colliding():
		return sensors[sensor].get_collision_normal()
	return null

func _process(delta: float) -> void:
	##new rotation
	_check_new_rotation(delta)
	_update_to_new_rotation(delta)

func _check_new_rotation(_delta: float) -> void:
	if not is_rotating:
		var getting_on_wall: bool = false
		var floor_normal = get_sensor_normal("floor")
		for direction in ["ui_up", "ui_down", "ui_right", "ui_left"]:
			var sensor_normal = get_sensor_normal(direction)
			if (
				Input.is_action_pressed(direction) and
				sensor_normal != null
			):
				new_ground_normal = sensor_normal
				getting_on_wall = true
				break
			sensor_normal = get_sensor_normal("falling_"+direction)
			if (
				not player.player_physics.is_on_floor() and
				sensor_normal != null and
				floor_normal == null
			):
				new_ground_normal = sensor_normal
				getting_on_wall = true
				break
		if getting_on_wall:
			gravity_no_floor_timer.stop()
		elif floor_normal != null:
			gravity_no_floor_timer.stop()
			new_ground_normal = floor_normal
		elif gravity_no_floor_timer.is_stopped():
			gravity_no_floor_timer.start()

func _on_gravity_no_floor_timer_timeout() -> void:
	new_ground_normal = Vector3.UP

## update rotation values
func _update_to_new_rotation(delta: float) -> void:
	if (
		abs(ground_normal.angle_to(new_ground_normal)) > ground_normal_sensitivity
	):
		var modified_delta: float = delta * gravity_rotation_speed_modifier * rotation_speed
		is_rotating = true
		var moved_ground_normal := (
			ground_normal
			.move_toward(
				new_ground_normal, modified_delta
			)
			.normalized()
		)
		var angle: float
		if ground_normal == moved_ground_normal:
			angle = ground_normal.angle_to(
				ground_normal.move_toward(
					front,
					modified_delta
				)
			)
			front = front.rotated(ground_normal.cross(front).normalized(), angle)
			ground_normal = ground_normal.rotated(ground_normal.cross(front).normalized(), angle)
		else:
			angle = ground_normal.angle_to(moved_ground_normal)
			front = front.rotated(ground_normal.cross(moved_ground_normal).normalized(), angle)
			ground_normal = moved_ground_normal
		player.player_physics.up_direction = ground_normal
		player._rotate_player()
	else:
		is_rotating = false
