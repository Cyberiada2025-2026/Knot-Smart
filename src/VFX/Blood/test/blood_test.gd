extends Node

@export var particles: CPUParticles3D

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			particles.emitting = true
