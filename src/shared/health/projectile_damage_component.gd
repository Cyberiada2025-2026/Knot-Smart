class_name ProjectileDamageComponent
extends Node
## Deals damage based on the parent object's momentum.
## Requires parent to be a RigidBody3d.

@export var base_damage: float = 1.0
@export var max_damage: float = 5.0
@export var minimum_momentum: float = 0.2
@export var maximum_momentum: float = 5.0

@onready var rigid_body: RigidBody3D = get_parent()


func get_damage() -> float:
	var momentum = (
		(rigid_body.mass * rigid_body.linear_velocity * Engine.physics_ticks_per_second).length()
	)
	print(momentum)
	if momentum < minimum_momentum:
		return 0.0

	var damage_modifier = clampf(lerpf(minimum_momentum, maximum_momentum, momentum), 0, 1)
	damage_modifier = momentum - minimum_momentum
	print(damage_modifier)
	return lerpf(base_damage, max_damage, damage_modifier)
