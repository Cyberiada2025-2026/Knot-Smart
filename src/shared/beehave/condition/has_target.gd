@tool extends ConditionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.target != null:
		return SUCCESS
	else:
		return FAILURE
