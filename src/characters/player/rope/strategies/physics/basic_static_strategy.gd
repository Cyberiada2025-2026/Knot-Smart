class_name BasicStaticStrategy
extends Node


func get_strategy_type() -> RopeEnd.StrategyType:
	return RopeEnd.StrategyType.STATIC


func get_equilibrium(_other: RopeEnd):
	return get_parent().position


func release_force(_node: Node):
	return
