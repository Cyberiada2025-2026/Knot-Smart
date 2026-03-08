extends Control

signal loaded_instance(instance)

var path: String


func set_path(node_path: String):
	path = node_path


func _process(_delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(path, progress)
	print("Loading progress: ", progress[0])

	if progress[0] == 1.0:
		_instantiate_scene()


func _instantiate_scene():
	var scene = ResourceLoader.load_threaded_get(path)
	var instance = scene.instantiate()
	loaded_instance.emit(instance)
