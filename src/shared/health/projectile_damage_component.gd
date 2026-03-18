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
	if momentum < minimum_momentum:
		return 0.0

	var momentum_normalized = Utils.normalize(momentum, minimum_momentum, maximum_momentum)
	return lerpf(base_damage, max_damage, momentum_normalized)
