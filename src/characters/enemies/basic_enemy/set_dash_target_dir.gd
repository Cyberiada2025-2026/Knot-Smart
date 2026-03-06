@tool
extends ActionLeaf

@export var distance := 100.0

func tick(actor: Node, blackboard: Blackboard) -> int:
	var player_pos : Vector3 = actor.get_target_pos()
	var enemy_pos : Vector3 = actor.global_position
	var temp_pos := (player_pos - enemy_pos) * distance
	actor.navigation_agent_3d.set_ta
	return SUCCESS
