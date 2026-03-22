class_name GravityController
extends Node3D

signal gravity_no_floor_timer_timeout

@export var player: Player
@export_category("sensors")
@export var floor_sensor: RayCast3D
@export var front_sensor: RayCast3D
@export var back_sensor: RayCast3D
@export var right_sensor: RayCast3D
@export var left_sensor: RayCast3D
@export_category("timers")
@export var gravity_no_floor_timer: Timer

var are_sensors_active: bool = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_gravity_controller"):
		are_sensors_active = not are_sensors_active

## return detected floor normal or Vector3.UP if are_sensors_active is false or null otherwise
func get_floor_normal():
	if not are_sensors_active:
		return Vector3.UP
	if floor_sensor.is_colliding():
		return floor_sensor.get_collision_normal()
	return null

## return detected FRONT wall normal or null otherwise
func get_front_normal():
	if are_sensors_active and front_sensor.is_colliding():
		return front_sensor.get_collision_normal()
	return null

## return detected BACK wall normal or null otherwise
func get_back_normal():
	if are_sensors_active and back_sensor.is_colliding():
		return back_sensor.get_collision_normal()
	return null

## return detected RIGHT wall normal or null otherwise
func get_right_normal():
	if are_sensors_active and right_sensor.is_colliding():
		return right_sensor.get_collision_normal()
	return null

## return detected LEFT wall normal or null otherwise
func get_left_normal():
	if are_sensors_active and left_sensor.is_colliding():
		return left_sensor.get_collision_normal()
	return null


func start_gravity_no_floor_timer() -> void:
	gravity_no_floor_timer.start()

func reset_gravity_no_floor_timer() -> void:
	gravity_no_floor_timer.stop()

func gravity_no_floor_timer_is_stopped() -> bool:
	return gravity_no_floor_timer.is_stopped()

func _on_gravity_no_floor_timer_timeout() -> void:
	gravity_no_floor_timer_timeout.emit()
