@tool extends ActionLeaf

@export var searched : StringName
@export var nav_agent : NavigationAgent3D

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var target : Node3D = actor.get_object_around(searched)
	if target == null:
		return FAILURE
	
	if searched == "Player":
		actor.target = target
	elif searched == "Interest":
		var pos := target.global_position
		actor.navigation_agent_3d.set_target_position(pos)
	return SUCCESS
