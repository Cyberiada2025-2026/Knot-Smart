@tool extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if(!actor.is_retreating):
		actor.navigation_agent_3d.set_target_position(actor.target.global_position)
	return SUCCESS
