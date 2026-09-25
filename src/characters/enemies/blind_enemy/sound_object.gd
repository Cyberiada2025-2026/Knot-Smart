class_name SoundObject
extends Node3D

@export var destroy_timer: float = 10.0;

func _process(delta: float) -> void:
	destroy_timer -= delta;
	if(destroy_timer < 0.0):
		queue_free();