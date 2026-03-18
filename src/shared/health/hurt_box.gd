class_name HurtBox
extends Area3D

@export var base_damage: float = 1.0

## Minimum velocity at which damage is applied. Otherwise the damage is 0.
@export var minimum_velocity: float = 0.0
## Minimum velocity at  which critical_multiplier is applied.
@export var critical_velocity: float = 0.0
## Multiplier applied to the base_damage at critical_velocity
@export var critical_multiplier: float = 1.0

var _velocity: float
var _prev_position: Vector3


func get_damage() -> float:
	var critical_velocity_multiplier = (
		critical_multiplier if _velocity >= critical_velocity else 1.0
	)
	return base_damage * (_velocity >= minimum_velocity as int) * critical_velocity_multiplier


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	_velocity = global_position.distance_to(_prev_position) / delta
	_prev_position = global_position
