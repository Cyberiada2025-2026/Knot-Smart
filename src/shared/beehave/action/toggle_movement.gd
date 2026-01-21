@tool extends ActionLeaf

@export var can_move : bool

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.toggle_movement(can_move)
	return SUCCESS
