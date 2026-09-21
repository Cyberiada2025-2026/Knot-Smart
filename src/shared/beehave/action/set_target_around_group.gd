@tool
class_name SetTargetAroundGroup
extends ActionLeaf

@export var target_group_name: StringName = "Player"
@export var min_distance_to_target: float = 5.0
@export var max_distance_to_target: float = 15.0


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	var actor = _actor as EnemyActor

	var target_in_group = get_tree().get_first_node_in_group(target_group_name) as Node3D
	if target_in_group == null:
		return FAILURE

	var random_point = Utils.get_random_point_in_circular_ring(
		min_distance_to_target, max_distance_to_target, target_in_group.global_position
	)

	actor.navigation_agent_3d.set_target_position(actor.get_point_on_map(random_point))

	return SUCCESS
