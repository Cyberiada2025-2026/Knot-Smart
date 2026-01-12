@tool extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.global_position.distance_to(actor.target.global_position) < actor.ATTACK_RANGE:
		return SUCCESS
	else :
		return FAILURE
