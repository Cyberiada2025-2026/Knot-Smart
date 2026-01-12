@tool extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.toggle_movement(true)
	return SUCCESS
