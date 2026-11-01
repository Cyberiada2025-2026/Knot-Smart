class_name Setting

signal updated(value: Variant)

var _path: SettingPath
var path: SettingPath:
	get:
		return _path

var _default_value: Variant

var _value: Variant
var value: Variant:
	get:
		return _value
	set(new_value):
		_value = new_value
		updated.emit(new_value)

func _init(setting_path: SettingPath, default_value: Variant) -> void:
	_default_value = default_value
	_value = default_value
	_path = setting_path
	
	SettingsManager.register_setting(self)

func restore_default():
	value = _default_value
