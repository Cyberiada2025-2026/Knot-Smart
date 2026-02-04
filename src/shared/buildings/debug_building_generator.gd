@tool
class_name DebugBuildingGenerator
extends Resource
## Generates initial_cells for the room generator based on provided start and end vectors.
## Fully deterministic.

@export_group("Initial Cells Data")
@export var initial_cells_start: Array[Vector3i] = []
@export var initial_cells_end: Array[Vector3i] = []


func get_building_cells() -> Array[Cell]:
	var initial_cells: Array[Cell] = []
	for i in initial_cells_start.size():
		initial_cells.push_back(Cell.new(initial_cells_start[i], initial_cells_end[i]))

	return initial_cells
