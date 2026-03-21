@tool
extends ActionLeaf

@export var can_move: bool


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.can_move = can_move
	return SUCCESS
