class_name BasicKinematicStrategy
extends Node


const PULL_UNIT = 1.0
var pull = 0.0


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.KINEMATIC


func get_equilibrium(current: RopeEnd, other: RopeEnd):
	var unit_direction = (current.position - other.position).normalized()
	return current.position - unit_direction * pull


func release_force(end: RopeEnd, node: Node):
	var direction = end.other.position - end.position
	node.velocity += 2 * direction


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("rope_axis_down"):
		print("Increased pull")
		pull -= PULL_UNIT
	elif event.is_action_released("rope_axis_up"):
		print("Decreased pull")
		pull += PULL_UNIT
