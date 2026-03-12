class_name CameraHelper
extends Camera3D

@export var camera: Node3D
@export var scene: Control

var reference: Node3D


func _process(_delta: float) -> void:
	if reference != null:
		camera.global_transform = reference.global_transform


func set_reference(ref: Node3D) -> void:
	reference = ref
