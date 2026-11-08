class_name SoundObject
extends Node3D

@export var time_to_destroy: float = 10.0

func _ready() -> void:
	get_tree().create_timer(time_to_destroy).timeout.connect(queue_free)
