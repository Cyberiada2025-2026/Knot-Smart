@tool
class_name TimePeriod
extends Resource

@export var name: String
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var duration: float = 10.0
@export var color_lut: Texture3D
## Information whether this time period is considered night for gameplay reasons.
@export var is_night: bool
