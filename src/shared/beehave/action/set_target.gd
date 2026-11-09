@tool
class_name SetTarget
extends ActionLeaf

@export var searched_group: StringName


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var target: Node3D = actor.get_closest_target(searched_group)
	if target == null:
		return FAILURE

	if searched_group == "Player":
		actor.target = target
	else:
		actor.navigation_agent_3d.set_target_position(target.global_position)
	return SUCCESS
