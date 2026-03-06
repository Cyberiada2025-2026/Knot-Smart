@tool
extends ActionLeaf

@export var does_retreat : bool

func tick(actor: Node, blackboard: Blackboard) -> int:
	actor.is_retreating = does_retreat
	return SUCCESS
