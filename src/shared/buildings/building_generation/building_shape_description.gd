@tool
class_name BuildingShapeDescription
extends Node

@export var is_visible: bool = false
@export var gridmap: GridMap

func get_cells() -> Array[Cell]:
	var cells: Array[Cell]
	cells.assign(find_children("", "BoxShape", false, true).map(func(box): return box.to_cell()))
	return cells

func _process(_delta: float) -> void:
	if is_visible:
		for box in find_children("", "BoxShape", false, true):
			box.draw_visualization(gridmap.global_position, Quaternion.from_euler(gridmap.global_rotation), gridmap.cell_size)
