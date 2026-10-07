@tool
class_name IsTargetNearby
extends ConditionLeaf

@export var searched: StringName
@export var custom_desired_distance: bool = false
@export_range(0.0, 10000.0, 0.1) var custom_desired_dist_value: float = 0.0


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if custom_desired_distance:
		if actor.is_group_member_nearby(searched, custom_desired_dist_value):
			return SUCCESS
		return FAILURE

	if actor.is_group_member_nearby(searched):
		return SUCCESS
	return FAILURE
