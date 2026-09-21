@tool
class_name IsTargetNearby
extends ConditionLeaf

@export var searched: StringName
@export var custom_desired_dist: float = 0.0;


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if custom_desired_dist > 0.0 && actor.is_group_member_nearby(searched, custom_desired_dist):
		return SUCCESS
	if custom_desired_dist == 0.0 && actor.is_group_member_nearby(searched):
		return SUCCESS
	return FAILURE
