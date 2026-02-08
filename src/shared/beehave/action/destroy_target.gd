@tool extends ActionLeaf

@export var target_group : StringName

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.destroy_target(target_group)
	return SUCCESS
