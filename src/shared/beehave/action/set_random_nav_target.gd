@tool
class_name SetRandomNavTarget
extends ActionLeaf

var random_point_around_player: bool = true
var random_point_pivot: Vector3


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if random_point_around_player:
		actor.set_random_nav_target()
	else:
		actor.set_random_nav_target_near(random_point_pivot)
	return SUCCESS
