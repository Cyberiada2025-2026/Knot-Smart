class_name BasicDynamicStrategy
extends Node

var length


func _init(min_length):
	self.length = min_length


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.DYNAMIC


func get_equilibrium(other: RopeEnd) -> Vector3:
	var direction = get_parent().position - other.position
	var equilibrium
	match other.get_strategy_type():
		RopeEnd.StrategyType.STATIC:
			equilibrium = other.position - direction * length
		RopeEnd.StrategyType.DYNAMIC:
			var midpoint = (get_parent().position + other.position) / 2
			equilibrium = midpoint - direction * 0.5 * length
		RopeEnd.StrategyType.KINEMATIC:
			equilibrium = other.strategy.get_equilibrium(get_parent())

	return equilibrium


func release_force(node: Node):
	var accel = get_parent().get_hooke_accel()
	node.apply_impulse(-accel)
