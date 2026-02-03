@tool
class_name CellGenerator
extends Node

enum Direction {
	Y,
	X,
	Z,
}

var room_generator: RoomGenerator

func generate_cells(_room_generator: RoomGenerator) -> void:
	room_generator = _room_generator
	room_generator.cells = room_generator.initial_cells.duplicate_deep()

	split_cells()


func split_cells():
	if room_generator.cells.size() == 0:
		return
	while true:
		var cell = pop_next_cell()
		if cell == null:
			break

		split(cell)


func pop_next_cell() -> Cell:
	for i in room_generator.cells.size():
		var cell = room_generator.cells[i]
		if cell.is_larger_than(room_generator.generation_params.max_size):
			room_generator.cells.remove_at(i)
			return cell
	return null


func split(cell: Cell) -> void:
	var direction = self.get_split_direction(cell)

	var e1: Vector3i = cell.end
	var s2: Vector3i = cell.start

	match direction:
		Direction.X:
			var split_point = randi_range(
				room_generator.generation_params.min_size.x, cell.size_x() - room_generator.generation_params.min_size.x
			)
			e1.x = cell.start.x + split_point
			s2.x = cell.start.x + split_point
		Direction.Y:
			var split_point = randi_range(
				room_generator.generation_params.min_size.y, cell.size_y() - room_generator.generation_params.min_size.y
			)
			e1.y = cell.start.y + split_point
			s2.y = cell.start.y + split_point
		Direction.Z:
			var split_point = randi_range(
				room_generator.generation_params.min_size.z, cell.size_z() - room_generator.generation_params.min_size.z
			)
			e1.z = cell.start.z + split_point
			s2.z = cell.start.z + split_point

	var c1 = Cell.new(cell.start, e1)
	var c2 = Cell.new(s2, cell.end)

	room_generator.cells.push_back(c1)
	room_generator.cells.push_back(c2)


func get_split_direction(cell: Cell) -> Direction:
	var y_split_chance = randi_range(0, 2)
	if (
		(cell.size_y() > room_generator.generation_params.min_size.y and y_split_chance != 0)
		or (cell.size_x() <= room_generator.generation_params.min_size.x && cell.size_z() <= room_generator.generation_params.min_size.z)
	):
		return Direction.Y

	if cell.size_x() <= room_generator.generation_params.min_size.x:
		return Direction.Z
	if cell.size_z() <= room_generator.generation_params.min_size.z:
		return Direction.X

	var randomizer = randi_range(-room_generator.generation_params.split_dir_rand, room_generator.generation_params.split_dir_rand)

	var diff = cell.size_x() - cell.size_z()
	var randomized_diff = diff + randomizer

	if randomized_diff <= 0:
		return Direction.Z
	return Direction.X
