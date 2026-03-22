class_name ToggleableArea
extends Area3D
## An area that can be toggled.
## or be enabled for the specified duration
## when the enable_until_timeout() function is called.


func set_disabled(value: bool) -> void:
	for child in find_children("", "CollisionShape3D"):
		child.disabled = value


func _ready() -> void:
	set_disabled(true)


func enable_until_timeout(duration: float) -> void:
	set_disabled(false)
	await get_tree().create_timer(duration).timeout
	set_disabled(true)
