extends Camera3D

@export var camera: Node3D

func _process(_delta: float) -> void:
	self.global_transform = camera.global_transform
