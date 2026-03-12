@tool
class_name TimePeriod
extends Node

signal duration_changed

@export_custom(PROPERTY_HINT_NONE, "suffix:s") var duration: float = 10.0:
	set(value):
		duration = value
		duration_changed.emit()

@export var color_lut: Texture3D
## Information whether this time period is considered night for gameplay reasons.
@export var is_night: bool


func _to_string() -> String:
	return name
