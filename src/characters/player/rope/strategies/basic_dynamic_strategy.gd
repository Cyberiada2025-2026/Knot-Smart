class_name BasicDynamicStrategy
extends Node


var length

func _init(min_length):
	self.length = min_length

func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.DYNAMIC

func get_equilibrium(current: RopeEnd, other: RopeEnd) -> Vector3:
	var direction = current.position - other.position
	var equilibrium
	match other.get_strategy_type():
		RopeEnd.StrategyType.STATIC:
			equilibrium = other.position - direction * length
		RopeEnd.StrategyType.DYNAMIC:
			var midpoint = (current.position + other.position)/2
			equilibrium = midpoint - direction * 0.5 * length
		RopeEnd.StrategyType.KINEMATIC:
			equilibrium = other.position

	return equilibrium

func release_force(end: RopeEnd, node: Node):
	var accel = end.get_hooke_accel()
	node.apply_impulse(-accel)
