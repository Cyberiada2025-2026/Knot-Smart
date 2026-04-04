@tool
class_name SetAttackArea
extends ActionLeaf

@export var area_disabled: bool = false
@export var attack_area: ToggleableArea


func tick(_actor: Node, _blackboard: Blackboard) -> int:
	attack_area.set_disabled(area_disabled)

	return SUCCESS
