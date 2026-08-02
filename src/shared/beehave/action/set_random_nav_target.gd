@tool
class_name SetRandomNavTarget
extends ActionLeaf

@export var set_random_target_strategy: Node;

func tick(actor: Node, _blackboard: Blackboard) -> int:
	set_random_target_strategy.set_random_nav_target(actor);
	return SUCCESS
