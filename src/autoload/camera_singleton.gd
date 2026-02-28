extends Node

var camera_setup = preload("uid://rnx3yu0ofiwg")
var instance: Node3D
var main_camera: Camera3D


func _ready() -> void:
	instance = camera_setup.instantiate()
	add_child(instance)
	main_camera = instance.camera

func get_instance() -> Node3D:
	return instance

func get_main_camera() -> Camera3D:
	return main_camera
