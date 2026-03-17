class_name BasicKinematicStrategy
extends Node


const PULL_UNIT = 1.0
var pull = 0.0


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.KINEMATIC


func get_equilibrium(current: RopeEnd, other: RopeEnd):
	var new_pull = pull

	if Input.is_action_just_released("rope_axis_down"):
		new_pull -= PULL_UNIT
	elif Input.is_action_just_released("rope_axis_up"):
		new_pull = clampf(new_pull + PULL_UNIT, new_pull, 0.0)
	
	if current.position.distance_squared_to(other.position) > 1.0 \
		or abs(new_pull) < abs(pull):
		pull = new_pull
	
	var unit_direction = (current.position - other.position).normalized()
	return current.position - unit_direction * pull


func release_force(end: RopeEnd, node: Node):
	var direction = end.other.position - end.position
	node.velocity += 2 * direction
