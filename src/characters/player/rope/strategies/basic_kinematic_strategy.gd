class_name BasicKinematicStrategy
extends Node


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.KINEMATIC

func get_equilibrium(current: RopeEnd, _other: RopeEnd):
	return current.position

func release_force(end: RopeEnd, node: Node):
	var direction = end.other.position - end.position
	node.velocity += 2 * direction
