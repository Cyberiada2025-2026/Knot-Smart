extends Node

var id: int = ResourceUID.text_to_id("uid://rnx3yu0ofiwg")
var camera_setup = load(ResourceUID.get_id_path(id))
var instance: Node3D
var main_camera: Camera3D


func _ready() -> void:
	instance = camera_setup.instantiate()
	add_child(instance)
	main_camera = instance.camera
