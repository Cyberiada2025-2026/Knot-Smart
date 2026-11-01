class_name SettingPath

var path_array: Array[String]

func _init(setting_path: Array[String]):
	path_array = setting_path

static func from_string(path_string: String, separator: String = "/") -> SettingPath:
	var setting_path := path_string.split(separator, false)
	return SettingPath.new(setting_path)

func _to_string() -> String:
	return "SettingsPath(" + str(path_array) + ")"
