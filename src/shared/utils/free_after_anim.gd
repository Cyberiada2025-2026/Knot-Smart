extends Node

@export var anim: StringName

func on_end(anim_name: StringName) -> void:
	if (anim_name == anim):
		queue_free()
