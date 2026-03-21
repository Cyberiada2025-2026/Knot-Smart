@tool
class_name HasReachedTarget
extends ConditionLeaf

@export var desired_distance: float


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor = actor as EnemyActor
	var curr_dist = actor.global_position.distance_squared_to(actor.get_target_pos())

	if curr_dist < pow(desired_distance, 2):
		return SUCCESS
	return RUNNING
