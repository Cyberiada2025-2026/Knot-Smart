@tool
extends ConditionLeaf

@export var searched: StringName


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_group_member_nearby(searched):
		return SUCCESS
	else:
		return FAILURE
