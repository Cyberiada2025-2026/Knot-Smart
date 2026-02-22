@tool
extends ActionLeaf


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.set_random_direction()
	return SUCCESS
