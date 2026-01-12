extends ConditionLeaf

func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.check_around_for("Player"):
		var target : Node3D = actor.get_object_around("Interest")
		actor.target = target
		return SUCCESS
	else:
		return FAILURE
