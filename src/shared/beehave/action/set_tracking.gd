@tool
extends ActionLeaf

@export var should_track_target: bool


func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.should_track_target = should_track_target
	return SUCCESS
