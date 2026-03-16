class_name HealthComponent
extends Node

signal health_changed(new_value: float)
signal max_health_changed(new_value: float)
signal health_depleted

@export var debug_log: bool = false

@export var max_health: float = 10.0:
	set(value):
		max_health = max(value, 0)
		health = health
		if debug_log:
			print("Max health changed to ", max_health)
		max_health_changed.emit(max_health)

@export var health: float = 10.0:
	set(value):
		health = clamp(value, 0, max_health)
		if debug_log:
			print("Health changed to ", health)
		health_changed.emit(health)

		if health == 0.0:
			if debug_log:
				print("Health depleted")
			health_depleted.emit()
