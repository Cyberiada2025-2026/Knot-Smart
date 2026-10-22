extends Node

@export var _settings_file_path: String = "user://settings.json"
@export var _default_settings_file_path: String = "res://autoload/settings/default_settings.json"

var _settings: Dictionary
var _listeners: Dictionary[Array, Array]
# this is actually a Dictionary[Array[String], Array[Callable]], however:
#	`Parse Error: Nested typed collections are not supported.`


func _ready() -> void:
	# initialize _settings with defaults, replace all changed values with user-specific settings,
	# and then save settings.
	#
	# this is to ensure that if a new key was added to the default settings,
	# the change will also be reflected in user-specific settings, if it wasn't there already.
	load_default_settings()
	var loaded_settings = _settings.duplicate_deep()
	if FileAccess.file_exists(_settings_file_path):
		load_settings()
		DictionaryUtilities.deep_merge(_settings, loaded_settings)
	_settings = loaded_settings
	save_settings()


func _call_listeners(path: Array[String], value: Variant) -> void:
	if _listeners.has(path):
		for callable: Callable in _listeners[path]:
			callable.call(value)


func _call_all_listeners() -> void:
	for path in _listeners.keys():
		var listeners := _listeners[path]
		for callable in listeners:
			callable.call(get_value(path))


## Returns two values: error (bool) and result (Variant)
func _resolve_path(path: Array[String], create_missing_keys: bool = false) -> Array:
	var target = _settings
	for key in path:
		if target is not Dictionary:
			printerr(key, " is not a dictionary in path: ", path)
			return [true, null]

		if target.has(key):
			target = target[key]
		else:
			if create_missing_keys:
				target[key] = {}
				target = target[key]
			else:
				printerr(key, " does not exist in path: ", path)
				return [true, null]

	return [false, target]


func load_settings() -> void:
	load_settings_from_path(_settings_file_path)


func load_default_settings() -> void:
	load_settings_from_path(_default_settings_file_path)


func load_settings_from_path(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("could not open settings file: ", path)
		_settings = {}
		return
	var settings_string = file.get_as_text()

	_settings = JSON.parse_string(settings_string)

	_call_all_listeners()


func save_settings() -> void:
	save_settings_to_path(_settings_file_path)


func save_settings_to_path(path: String) -> void:
	var settings_string = JSON.stringify(_settings, "\t", false)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(settings_string)


## Overwrites the user setting file with the contents of default settings.
## Useful to clean up old user settings that were removed and are no longer in the defaults file.
func reset_settings() -> void:
	load_default_settings()
	save_settings()


func get_value(path: Array[String]):
	var result = _resolve_path(path)
	var error = result[0]
	var target = result[1]

	if error:
		printerr("failed resolving path: ", path)

	return target


func set_value(path: Array[String], value: Variant, create_missing_keys: bool = false) -> void:
	var result = _resolve_path(path.slice(0, path.size() - 1), create_missing_keys)
	# _resolve_path returns the value at the end of path.
	# By slicing the last element we are able to get the dictionary that the value is contained in
	# and actually change the value at the end of the path

	var error = result[0]
	var target = result[1]

	if error:
		printerr("failed resolving path: ", path)
		return

	target[path[-1]] = value
	_call_listeners(path, value)


## Note: listeners added by calling this method will [b]not[/b] be automatically removed.
## In most cases it's recommended to use [code]add_child(SettingListener.new(...))[/code].
func add_listener(path: Array[String], callable: Callable, call_immediately: bool = false) -> void:
	if _listeners.has(path):
		_listeners[path].append(callable)
	else:
		_listeners[path] = [callable]

	if call_immediately:
		callable.call(get_value(path))


func remove_listener(path: Array[String], callable: Callable) -> void:
	if _listeners.has(path):
		var index = _listeners[path].find(callable)
		if index != -1:
			_listeners[path].remove_at(index)
			return

	printerr("listener: ", callable, "not found in key: ", path)
