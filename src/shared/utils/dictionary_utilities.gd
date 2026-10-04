class_name DictionaryUtilities


## Deep-merge the [param source] dictionary into [param destination]. [br]
## Similar to [method Dictionary.merge] with [code]overwrite=true[/code],
## but also recursively deep-merges nested dictionaries.
static func deep_merge(source: Dictionary, destination: Dictionary) -> void:
	for key in source:
		if source[key] is Dictionary and destination.has(key):
			deep_merge(source[key], destination[key])
		else:
			destination[key] = source[key]


## Returns full paths to "leafs" - keys with values that are not dictionaries
## For example, the following dictionary:
## {
##   "audio": {
##     "mono": false,
##     "volume": {
##       "main": 100,
##       "effects": 50
##     }
##   }
## }
## Would return following Paths:
##  - ["audio", "mono"]
##  - ["audio", "volume", "main"]
##  - ["audio", "volume", "effects"]
static func get_all_leaf_paths(source: Dictionary) -> Array[Array]:
	var found_paths: Array[Array] = []

	_get_all_leaf_paths_internal(source, [], found_paths)

	return found_paths


static func _get_all_leaf_paths_internal(
	source: Dictionary, path: Array[String], found_paths: Array[Array]
):
	for key in source:
		var value = source[key]
		var extended_path: Array[String] = path.duplicate()
		extended_path.append(key)
		if value is Dictionary:
			_get_all_leaf_paths_internal(source[key], extended_path, found_paths)
		else:
			found_paths.append(extended_path)
