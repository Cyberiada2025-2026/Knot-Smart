@tool
extends ConditionLeaf

@export var desired_distance := 1.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	#IDK WHY BUT ACTOR.IS_AT_DESTINATION DOESNT WORK?
	if actor.global_position.distance_to(actor.get_target_pos()) < desired_distance:
		return SUCCESS
	return RUNNING
