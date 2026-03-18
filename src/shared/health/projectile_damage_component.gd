class_name ProjectileDamageComponent
extends Node
## Requires parent to be a RigidBody3d

@onready var rigid_body: RigidBody3D = get_parent()

@export var base_damage: float = 1.0
@export var max_damage: float = 5.0
@export var minimum_momentum: float = 5.0
@export var maximum_momentum: float = 10.0

func get_damage() -> float:
	var momentum = rigid_body.mass * rigid_body.linear_velocity * Engine.physics_ticks_per_second
	if momentum < minimum_momentum:
		return 0.0
	
	var damage_modifier = clampf(lerpf(minimum_momentum, maximum_momentum, momentum), 0, 1)
	return lerpf(base_damage, max_damage, damage_modifier)

