extends Node

var field_of_view := Setting.new(SettingPath.from_string("graphics/field of view"), 90)
var use_crt_filter := Setting.new(SettingPath.from_string("accessibility/use crt filter"), true)

var debug_settings_random_value := Setting.new(
	SettingPath.from_string("debug scenes/settings_debug/random value"),
	0
)
