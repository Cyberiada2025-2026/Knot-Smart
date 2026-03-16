class_name HurtBox
extends Area3D

@export var damage: float = 1.0
@export var is_disabled: bool = false:
	set(value):
		is_disabled = value
		for c in find_children("", "CollisionShape3D"):
			c.set_deferred("disabled", is_disabled)


func _ready() -> void:
	is_disabled = is_disabled
