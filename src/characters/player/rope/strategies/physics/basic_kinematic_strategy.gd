class_name BasicKinematicStrategy
extends Node

const PULL_UNIT = 1.0
var pull = 0.0


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.KINEMATIC


func get_equilibrium(other: RopeEnd):
	var new_pull = pull

	if Input.is_action_just_released("rope_pull"):
		new_pull += PULL_UNIT
	elif Input.is_action_just_released("rope_push"):
		new_pull = clampf(new_pull - PULL_UNIT, 0.0, new_pull)

	if get_parent().position.distance_squared_to(other.position) > 1.0 or abs(new_pull) < abs(pull):
		pull = new_pull

	return get_parent().position + other.position.direction_to(get_parent().position) * pull


func release_force(node: Node):
	var direction = get_parent().other.position - get_parent().position
	node.velocity += 2 * direction
