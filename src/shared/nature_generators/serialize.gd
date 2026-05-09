class_name Serialize
extends Node


static func serialize(scene: PackedScene, object: Node3D, dir: String) -> Node:
	var result = scene.pack(object)
	if result == OK:
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.make_dir_absolute(dir)
		var error = ResourceSaver.save(
			scene,
			dir + "/object%d.tscn" % scene.get_rid().get_id())
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
		return scene.instantiate()
	return null
