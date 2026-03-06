@tool
extends ActionLeaf

@export var distance := 10.0
@export var first : ENTITIES
@export var second : ENTITIES

var dict : Dictionary = {
	ENTITIES.PLAYER : null,
	ENTITIES.ENEMY : null
}

func tick(actor: Node, blackboard: Blackboard) -> int:
	dict[ENTITIES.PLAYER] = actor.get_target_pos()
	dict[ENTITIES.ENEMY] = actor.global_position
	
	var temp_pos : Vector3 = (dict[first] - dict[second]).normalized() * distance
	actor.navigation_agent_3d.set_target_position(temp_pos)
	return SUCCESS

enum ENTITIES {
	PLAYER,
	ENEMY
}
