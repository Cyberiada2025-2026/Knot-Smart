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
## Minimum velocity at which critical_multiplier is applied.
@export var critical_velocity: float = 0.0
## Multiplier applied to the base_damage at critical_velocity
@export var critical_multiplier: float = 1.0

var _prev_position: Vector3
var velocity: float


func get_damage() -> float:
	var critical_velocity_multiplier = critical_multiplier if velocity >= critical_velocity else 1.0
	return base_damage * (velocity >= minimum_velocity as int) * critical_velocity_multiplier

func _ready() -> void:
	is_disabled = is_disabled


func _physics_process(delta: float) -> void:
	velocity = global_position.distance_to(_prev_position) / delta
	_prev_position = global_position

