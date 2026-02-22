extends Node

var current_scene = null
var loading_scene = null
var loading_screen = preload("uid://crhln4qdp4hph")


func _ready():
	current_scene = get_tree().current_scene


func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path):
	current_scene.free()

	# Params:
	# "" - type hint - default value
	# true - use_sub_threads - enables accelerated loading using multithreading
	ResourceLoader.load_threaded_request(path, "", true)
	loading_scene = loading_screen.instantiate()
	loading_scene.set_path(path)

	get_tree().root.add_child(loading_scene)
	get_tree().current_scene = loading_scene

	current_scene = await loading_scene.loaded_instance
	get_tree().root.add_child(current_scene)

	loading_scene.queue_free()
	get_tree().current_scene = current_scene
