class_name UIReparent
extends Control

func _ready() -> void:
	await get_tree().process_frame
	reparent(CameraSingleton.get_main_camera())
