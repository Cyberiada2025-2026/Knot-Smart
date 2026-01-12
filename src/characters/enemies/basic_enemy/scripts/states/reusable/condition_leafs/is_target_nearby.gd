@tool extends ConditionLeaf

@export var searched : StringName

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.check_around_for(searched):
		return SUCCESS
	else:
		return FAILURE
