@tool
extends ConditionLeaf

enum Type { GREATER, LOWER }

@export var desired_distance: float
@export var compare_type: Type = Type.LOWER


func tick(actor: Node, _blackboard: Blackboard) -> int:
	#IDK WHY BUT ACTOR.IS_AT_DESTINATION DOESNT WORK?
	if (
		actor.global_position.distance_to(actor.get_target_pos()) < desired_distance
		&& compare_type == Type.LOWER
	):
		return SUCCESS
	if (
		actor.global_position.distance_to(actor.get_target_pos()) > desired_distance
		&& compare_type == Type.GREATER
	):
		return SUCCESS
	if compare_type == Type.GREATER:
		return FAILURE

	return RUNNING
