class_name Serializer
extends Node


static func serialize(scene: PackedScene, object: Node3D, dir: String, params: Resource) -> Node:
	var result = scene.pack(object)
	if result == OK:
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.make_dir_absolute(dir)
		var obj_hash = JSON.stringify(JSON.from_native(params, true)).hash()
		var error = ResourceSaver.save(scene, dir + "/object%d.tscn" % obj_hash)
		if error != OK:
			push_error("An error occurred while saving the scene to disk.")
		return scene.instantiate()
	return null


static func load(dir: String, params: Resource) -> Node:
	if params == null:
		return null
	var obj_hash = JSON.stringify(JSON.from_native(params, true)).hash()
	if !ResourceLoader.exists(dir + "/object%d.tscn" % obj_hash):
		print("Resource doesn't exist")
		return null
	var scene = ResourceLoader.load(dir + "/object%d.tscn" % obj_hash)

	return scene.instantiate()
