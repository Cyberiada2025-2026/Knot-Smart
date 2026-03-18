class_name TimedArea
extends Area3D

@export var duration: float = 0.1


func set_disabled(value: bool) -> void:
	for child in find_children("", "CollisionShape3D"):
		child.disabled = value


func _ready() -> void:
	set_disabled(true)


func attack() -> void:
	set_disabled(false)
	await get_tree().create_timer(duration).timeout
	set_disabled(true)
