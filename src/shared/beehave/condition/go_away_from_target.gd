@tool
extends ActionLeaf

@export var distance := 10.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_pos : Vector3 = actor.get_target_pos()
	var enemy_pos : Vector3 = actor.global_position
	var temp_pos := (enemy_pos - player_pos) * distance
	actor.navigation_agent_3d.set_target_position(temp_pos)
	return SUCCESS
