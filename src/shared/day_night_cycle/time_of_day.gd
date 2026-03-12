@tool
class_name TimeOfDay
extends Resource

@export var name: String
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var duration: float
@export var color_lut: Texture3D
## Information whether this time period is considered night for gameplay reasons.
@export var is_night: bool
