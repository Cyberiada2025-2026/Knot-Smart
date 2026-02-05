@tool
class_name BuildingShapeDescription
extends Node

func get_cells() -> Array[Cell]:
	var cells: Array[Cell]
	cells.assign(find_children("", "BoxShape", true, true).map(func(box): return box.to_cell()))
	return cells
