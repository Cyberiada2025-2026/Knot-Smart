class_name BasicKinematicStrategy
extends Node

const PULL_UNIT = 1.0
var pull = 0.0


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.KINEMATIC


func get_equilibrium(current: RopeEnd, other: RopeEnd):
	var new_pull = pull

	if Input.is_action_just_released("rope_pull"):
		new_pull += PULL_UNIT
	elif Input.is_action_just_released("rope_push"):
		new_pull = clampf(new_pull - PULL_UNIT, 0.0, new_pull)

	if current.position.distance_squared_to(other.position) > 1.0 or abs(new_pull) < abs(pull):
		pull = new_pull

	return current.position + other.position.direction_to(current.position) * pull


func release_force(end: RopeEnd, node: Node):
	var direction = end.other.position - end.position
	node.velocity += 2 * direction
