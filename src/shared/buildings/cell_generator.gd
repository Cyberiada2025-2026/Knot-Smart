@tool
class_name CellGenerator
extends Node

enum Direction {
	Y,
	X,
	Z,
}

var cells: Array[Cell] = []
var gen_params: RoomGenerationParams


func generate_cells(new_cells: Array[Cell], generation_params: RoomGenerationParams) -> Array[Cell]:
	cells = new_cells.duplicate_deep()
	gen_params = generation_params

	split_cells()
	return cells


func split_cells():
	if cells.size() == 0:
		return
	while true:
		var cell = pop_next_cell()
		if cell == null:
			break

		split(cell)


func pop_next_cell() -> Cell:
	for i in cells.size():
		var cell = cells[i]
		if cell.is_larger_than(gen_params.max_size):
			cells.remove_at(i)
			return cell
	return null


func split(cell: Cell) -> void:
	var direction = self.get_split_direction(cell)

	var e1: Vector3i = cell.end
	var s2: Vector3i = cell.start

	match direction:
		Direction.X:
			var split_point = randi_range(
				gen_params.min_size.x, cell.size_x() - gen_params.min_size.x
			)
			e1.x = cell.start.x + split_point
			s2.x = cell.start.x + split_point
		Direction.Y:
			var split_point = randi_range(
				gen_params.min_size.y, cell.size_y() - gen_params.min_size.y
			)
			e1.y = cell.start.y + split_point
			s2.y = cell.start.y + split_point
		Direction.Z:
			var split_point = randi_range(
				gen_params.min_size.z, cell.size_z() - gen_params.min_size.z
			)
			e1.z = cell.start.z + split_point
			s2.z = cell.start.z + split_point

	var c1 = Cell.new(cell.start, e1)
	var c2 = Cell.new(s2, cell.end)

	cells.push_back(c1)
	cells.push_back(c2)


func get_split_direction(cell: Cell) -> Direction:
	var y_split_chance = randi_range(0, 2)
	if (
		(cell.size_y() > gen_params.min_size.y and y_split_chance != 0)
		or (cell.size_x() <= gen_params.min_size.x && cell.size_z() <= gen_params.min_size.z)
	):
		return Direction.Y

	if cell.size_x() <= gen_params.min_size.x:
		return Direction.Z
	if cell.size_z() <= gen_params.min_size.z:
		return Direction.X

	var randomizer = randi_range(-gen_params.split_dir_rand, gen_params.split_dir_rand)

	var diff = cell.size_x() - cell.size_z()
	var randomized_diff = diff + randomizer

	if randomized_diff <= 0:
		return Direction.Z
	return Direction.X
