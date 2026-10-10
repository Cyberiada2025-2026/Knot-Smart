class_name SetRandomNavPivotToCurrentPos
extends SetRandomNavPivotInterface

@export var transform_node: Node3D

func set_random_nav_target(actor: Node) -> void:
	actor.set_random_nav_target_near(transform_node.global_position)
