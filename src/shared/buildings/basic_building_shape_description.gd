@tool
class_name BasicBuildingShapeDescription
extends Resource
## Generates initial_cells for the room generator based on provided start and end vectors.
## Fully deterministic.

@export_group("Initial Boxes")
@export var initial_boxes_start: Array[Vector3i] = []
@export var initial_boxes_end: Array[Vector3i] = []


func get_building_shape() -> Array[Cell]:
	var initial_cells: Array[Cell] = []
	for i in initial_boxes_start.size():
		initial_cells.push_back(Cell.new(initial_boxes_start[i], initial_boxes_end[i]))

	return initial_cells
