@tool
class_name SetTarget
extends ActionLeaf

@export var searched: StringName
@export var custom_desired_dist: float = 0.0;


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var target: Node3D = actor.get_object_around(searched, custom_desired_dist) if custom_desired_dist > 0.0 else actor.get_object_around(searched)

	if target == null:
		return FAILURE

	# actor.navigation_agent_3d.set_target_position(target.global_position)
	if searched == "Player":
		actor.target = target
	# elif searched == "Interest":
	# 	var pos := target.global_position
	else:
		actor.navigation_agent_3d.set_target_position(target.global_position)
	return SUCCESS
