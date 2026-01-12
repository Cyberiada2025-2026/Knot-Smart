@tool extends ActionLeaf

@export var searched : StringName

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var target : Node3D = actor.get_object_around(searched)
	if target == null:
		return FAILURE
	else:
		actor.target = target
		var pos := target.global_position
		actor.set_target_position(pos)
		return SUCCESS
