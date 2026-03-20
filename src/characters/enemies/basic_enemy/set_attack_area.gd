@tool
extends ActionLeaf

@export var area_disabled: bool = false
@export var attack_area: TogglableArea

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	attack_area.set_disabled(area_disabled)

	return SUCCESS
