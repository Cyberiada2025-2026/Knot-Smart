extends Node3D

@export var interval: float = 10.0
@export var object: PackedScene

var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= interval:
		timer = 0.0
		var instance = object.instantiate()
		add_child(instance)
		instance.position = Vector3.ZERO
