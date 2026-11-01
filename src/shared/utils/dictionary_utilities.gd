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


## Returns value at the end of path.
## For example, when:
## dict = {
##   "audio": {
##     "mono": false,
##     "volume": {
##       "main": 100,
##       "effects": 50
##     }
##   }
## }
## and path = ["audio", "volume", "main"],
## the return value would be: 100
static func get_value_at_path(dict: Dictionary, path: Array) -> Variant:
	var target = dict
	for key in path:
		target = target[key]
	return target

static func set_value_at_path(
	dict: Dictionary,
	path: Array,
	value: Variant,
	create_missing_keys: bool = true
) -> void:
	var target = dict
	for key in path.slice(0, path.size() - 1):
		if target is not Dictionary:
			printerr(key, " is not a dictionary in path: ", path)
			return
		
		if target.has(key):
			target = target[key]
		else:
			if create_missing_keys:
				target[key] = {}
				target = target[key]
			else:
				printerr(key, " does not exist in path: ", path)
				return
	target[path[-1]] = value

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
