@tool
extends ActionLeaf

@export var speed : float

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.set_speed(speed)
	return SUCCESS
