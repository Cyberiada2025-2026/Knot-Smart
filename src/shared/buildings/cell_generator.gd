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


func generate_rooms(new_cells: Array[Cell], generation_params: RoomGenerationParams) -> Array[Cell]:
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
		if cell.is_larger_than(gen_params.max_room_size):
			cells.remove_at(i)
			return cell
	return null


func split(cell: Cell) -> void:
	var split_data = self.get_split_direction(cell)
	var direction = split_data[0]
	var split_point = split_data[1]

	var e1: Vector3i = cell.end
	var s2: Vector3i = cell.start

	match direction:
		Direction.X:
			e1.x = cell.start.x + split_point
			s2.x = cell.start.x + split_point
		Direction.Y:
			e1.y = cell.start.y + split_point
			s2.y = cell.start.y + split_point
		Direction.Z:
			e1.z = cell.start.z + split_point
			s2.z = cell.start.z + split_point

	var c1 = Cell.create(cell.start, e1)
	var c2 = Cell.create(s2, cell.end)

	cells.push_back(c1)
	cells.push_back(c2)


func get_split_direction(cell: Cell) -> Array:
	var y_split_chance = randi_range(0, 2)
	if (
		(cell.size_y() > gen_params.min_room_size.y and y_split_chance != 0)
		or (
			cell.size_x() <= gen_params.min_room_size.x
			&& cell.size_z() <= gen_params.min_room_size.z
		)
	):
		return [
			Direction.Y,
			randi_range(gen_params.min_room_size.y, cell.size_y() - gen_params.min_room_size.y)
		]

	if cell.size_x() <= gen_params.min_room_size.x:
		return [
			Direction.Z,
			randi_range(gen_params.min_room_size.z, cell.size_z() - gen_params.min_room_size.z)
		]
	if cell.size_z() <= gen_params.min_room_size.z:
		return [
			Direction.X,
			randi_range(gen_params.min_room_size.x, cell.size_x() - gen_params.min_room_size.x)
		]

	var randomizer = randi_range(
		-gen_params.room_split_direction_randomizer, gen_params.room_split_direction_randomizer
	)

	var diff = cell.size_x() - cell.size_z()
	var randomized_diff = diff + randomizer

	if randomized_diff <= 0:
		return [
			Direction.Z,
			randi_range(gen_params.min_room_size.z, cell.size_z() - gen_params.min_room_size.z)
		]
	return [
		Direction.X,
		randi_range(gen_params.min_room_size.x, cell.size_x() - gen_params.min_room_size.x)
	]
