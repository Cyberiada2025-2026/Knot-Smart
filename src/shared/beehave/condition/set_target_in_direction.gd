@tool
class_name SetTargetInDirection
extends ActionLeaf

@export var distance := 10.0
@export var is_moving_away: bool


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var actor_pos: Vector3 = actor.global_position
	var target_pos: Vector3 = actor.get_target_pos()

	var direction = actor_pos.direction_to(target_pos)
	if is_moving_away:
		direction *= -1

	var target_point = actor.get_point_on_map(actor_pos + direction * distance)
	actor.navigation_agent_3d.set_target_position(target_point)

	return SUCCESS
