class_name GravityController
extends Node3D


@export var player: Player
@export_category("sensors")
@export var floor_sensor: RayCast3D
@export var front_sensor: RayCast3D

var are_sensors_active: bool = true


## return detected floor normal or Vector3.UP if are_sensors_active is false or null otherwise
func get_floor_normal():
	if not are_sensors_active:
		return Vector3.UP
	elif floor_sensor.is_colliding():
		return floor_sensor.get_collision_normal()
	else:
		return null

## return detected wall normal or null otherwise
func get_front_normal():
	if are_sensors_active and front_sensor.is_colliding():
		return front_sensor.get_collision_normal()
	else:
		return null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("turn_on-off_gravity_controller"):
		are_sensors_active = not are_sensors_active
