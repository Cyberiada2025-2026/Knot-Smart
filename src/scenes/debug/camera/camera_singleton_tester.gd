extends Node


func _ready() -> void:
	print(CameraSingleton.get_main_camera().position)
