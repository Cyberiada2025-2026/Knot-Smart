@tool extends ConditionLeaf

@export var attack_range := 5.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.global_position.distance_to(actor.get_target_pos()) < attack_range:
		return SUCCESS
	else :
		return FAILURE
