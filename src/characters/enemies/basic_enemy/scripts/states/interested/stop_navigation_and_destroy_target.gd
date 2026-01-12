@tool extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.target.queue_free()
	return SUCCESS
