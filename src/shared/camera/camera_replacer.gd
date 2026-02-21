extends Camera3D

@export var camera: Node3D

var reference: Node3D

func _process(_delta: float) -> void:
	if reference != null:
		camera.global_transform = reference.global_transform
