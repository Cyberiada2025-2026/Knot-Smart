extends Node

@export var _settings_file_path: String = "user://settings.json"

var _settings: Dictionary[String, Setting]
# It would be nice if this could be a Dictionary[SettingsPath, Setting],
# however all Godot objects are reference-types,
# so when we add a SettingsPath.new(["abc"]) to this dictionary
# and then check if it contains SettingsPath.new(["abc"]), it will always return false.
#
# Anyways, the key of this ditionary should be just str(your_setting_path)


func _ready() -> void:
	if FileAccess.file_exists(_settings_file_path):
		load_settings()
	else:
		save_settings()


func register_setting(setting: Setting) -> void:
	_settings[str(setting.path)] = setting


func load_settings() -> void:
	var file := FileAccess.open(_settings_file_path, FileAccess.READ)
	if file == null:
		printerr("could not open settings file: ", _settings_file_path)
		return
	var settings_string = file.get_as_text()
	var settings_dict = JSON.parse_string(settings_string)
	
	for path in DictionaryUtilities.get_all_leaf_paths(settings_dict):
		var setting_path := SettingPath.new(path)
		if str(setting_path) not in _settings:
			push_warning("Unrecognized setting (" + str(path) + ") found in " + _settings_file_path)
			continue
		_settings[str(setting_path)].value = DictionaryUtilities.get_value_at_path(settings_dict, path)


func save_settings() -> void:
	var serialized_settings = {}
	for key in _settings:
		var setting_path = key
		var setting = _settings[setting_path]
		DictionaryUtilities.set_value_at_path(serialized_settings, setting.path.path_array, setting.value)
	
	var settings_string = JSON.stringify(serialized_settings, "\t", false)
	var file := FileAccess.open(_settings_file_path, FileAccess.WRITE)
	file.store_string(settings_string)


## Overwrites the user setting file with the contents of default settings.
## Useful to clean up old user settings that were removed and are no longer in the defaults file.
func reset_settings() -> void:
	for setting in _settings.values():
		setting.restore_default()
