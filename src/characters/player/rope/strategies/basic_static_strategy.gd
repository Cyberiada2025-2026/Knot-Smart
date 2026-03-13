class_name BasicStaticStrategy
extends Node


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.STATIC


func get_equilibrium(current: RopeEnd, _other: RopeEnd):
	return current.position


func release_force(_end: RopeEnd, _node: Node):
	return
