extends Node

@export var particles: CPUParticles3D
@export var interval: float = 5.0

var timer: float = interval

func _process(delta: float) -> void:
	timer += delta
	if timer >= interval:
		particles.emitting = !particles.emitting
		timer = 0.0
