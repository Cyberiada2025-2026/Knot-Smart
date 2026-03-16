class_name HurtBox
extends Area3D

@export var base_damage: float = 1.0
@export var is_disabled: bool = false:
	set(value):
		is_disabled = value
		for c in find_children("", "CollisionShape3D"):
			c.set_deferred("disabled", is_disabled)

## Minimum velocity at which damage is applied. Otherwise the damage is 0.
@export var minimum_velocity: float = 0.0

var _prev_position: Vector3
var velocity: float


func get_damage() -> float:
	return base_damage * (velocity >= minimum_velocity as float)

func _ready() -> void:
	is_disabled = is_disabled


func _physics_process(delta: float) -> void:
	velocity = global_position.distance_to(_prev_position) / delta
	_prev_position = global_position

