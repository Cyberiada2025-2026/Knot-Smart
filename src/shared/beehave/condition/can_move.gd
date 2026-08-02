@tool
class_name CanMove
extends ConditionLeaf	

func tick(actor: Node, _blackboard: Blackboard) -> int:
	return actor.can_move;
