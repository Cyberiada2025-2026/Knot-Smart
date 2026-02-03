@tool
class_name CellGenerator
extends Node

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
	var cell_idx = room_generator.cells.find_custom(func(c): return c.is_larger_than(room_generator.generation_params.max_room_size))
	return room_generator.cells.pop_at(cell_idx) if cell_idx != -1 else null


func split(cell: Cell) -> void:
	var direction = self.get_split_direction(cell)

	var e1: Vector3i = cell.end
	var s2: Vector3i = cell.start

	match direction:
		Utils.Axis.X:
			var split_point = randi_range(
				room_generator.generation_params.min_room_size.x,
				cell.size_x() - room_generator.generation_params.min_room_size.x
			)
			e1.x = cell.start.x + split_point
			s2.x = cell.start.x + split_point
		Utils.Axis.Y:
			var split_point = randi_range(
				room_generator.generation_params.min_room_size.y,
				cell.size_y() - room_generator.generation_params.min_room_size.y
			)
			e1.y = cell.start.y + split_point
			s2.y = cell.start.y + split_point
		Utils.Axis.Z:
			var split_point = randi_range(
				room_generator.generation_params.min_room_size.z,
				cell.size_z() - room_generator.generation_params.min_room_size.z
			)
			e1.z = cell.start.z + split_point
			s2.z = cell.start.z + split_point

	var c1 = Cell.new(cell.start, e1)
	var c2 = Cell.new(s2, cell.end)

	room_generator.cells.push_back(c1)
	room_generator.cells.push_back(c2)


func get_split_direction(cell: Cell) -> Utils.Axis:
	var y_split_chance = randi_range(0, 2)
	if (
		(cell.size_y() > room_generator.generation_params.min_room_size.y and y_split_chance != 0)
		or (
			cell.size_x() <= room_generator.generation_params.min_room_size.x
			&& cell.size_z() <= room_generator.generation_params.min_room_size.z
		)
	):
		return Utils.Axis.Y

	if cell.size_x() <= room_generator.generation_params.min_room_size.x:
		return Utils.Axis.Z
	if cell.size_z() <= room_generator.generation_params.min_room_size.z:
		return Utils.Axis.X

	var split_dir_rand = (
		room_generator.generation_params.long_room_tendency * cell.max_side_length()
	)
	var randomizer = randi_range(-split_dir_rand, split_dir_rand)

	var diff = cell.size_x() - cell.size_z()
	var randomized_diff = diff + randomizer

	if randomized_diff <= 0:
		return Utils.Axis.Z
	return Utils.Axis.X
