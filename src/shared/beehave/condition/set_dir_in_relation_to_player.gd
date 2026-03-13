@tool
extends ActionLeaf


var entities_pos : Dictionary = {
	Entities.PLAYER : null,
	Entities.ENEMY : null,
}
@export var from : Entities
@export var to : Entities
@export var distance := 10.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	entities_pos[Entities.PLAYER] = actor.get_target_pos()
	entities_pos[Entities.ENEMY] = actor.global_position
	
	var direction : Vector3 = (entities_pos[to] - entities_pos[from]).normalized()
	var target_pos : Vector3 = entities_pos[Entities.ENEMY] + direction * distance
	
	var point = actor.get_point_on_map(target_pos)
	actor.navigation_agent_3d.set_target_position(point)
	return SUCCESS


enum Entities {
	PLAYER,
	ENEMY,
}
