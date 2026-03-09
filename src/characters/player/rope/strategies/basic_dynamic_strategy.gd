class_name BasicDynamicStrategy
extends Node

const StrategyType = RopeEnd.StrategyType

var length

func _init(min_length):
	self.length = min_length

func get_strategy_type() -> StrategyType:
	return StrategyType.DYNAMIC

func get_equilibrium(current: RopeEnd, other: RopeEnd) -> Vector3:
	var direction = current.position - other.position
	var equilibrium
	match other.get_strategy_type():
		StrategyType.STATIC:
			equilibrium = other.position - direction * length
		StrategyType.DYNAMIC:
			var midpoint = (current.position + other.position)/2
			equilibrium = midpoint - direction * 0.5 * length
		StrategyType.KINEMATIC:
			equilibrium = other.position

	return equilibrium

func release_force(end: RopeEnd, node: Node):
	var accel = end.get_hooke_accel()
	node.apply_impulse(-accel)
