@tool
class_name RotateRandom
extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
	ActorUtils.rotate_random(actor);
	return SUCCESS
