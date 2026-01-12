extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.t1:
		return SUCCESS
	else:
		return FAILURE
