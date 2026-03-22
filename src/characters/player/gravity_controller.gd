class_name GravityController
extends Node3D

@export var player: Player
@export_category("sensors")
@export var sensors: Dictionary[String, RayCast3D]
@export_category("timers")
@export var gravity_no_floor_timer: Timer

var are_sensors_active: bool = true


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
