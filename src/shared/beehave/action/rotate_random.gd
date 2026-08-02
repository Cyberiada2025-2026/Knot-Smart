@tool
class_name RotateRandom
extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.rotate_random();
	return SUCCESS
