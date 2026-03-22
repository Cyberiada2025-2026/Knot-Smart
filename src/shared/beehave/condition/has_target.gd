@tool
class_name HasTarget
extends ConditionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.target != null:
		return SUCCESS
	return FAILURE
