@tool
class_name IsTargetNearby
extends ConditionLeaf

@export var searched_group: StringName
@export var custom_distance: CustomDesiredDistance;


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var desired_dist: float = actor.default_search_distance;
	if custom_distance != null:
		desired_dist = custom_distance.custom_value

	if actor.is_group_member_nearby(searched_group, desired_dist):
		return SUCCESS
	return FAILURE
