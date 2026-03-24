@tool
class_name SetRandomNavTarget
extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.set_random_nav_target()
	return SUCCESS
