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

	var split_point = randi_range(
		room_generator.generation_params.min_room_size[direction],
		cell.size()[direction] - room_generator.generation_params.min_room_size[direction]
	)
	e1[direction] = cell.start[direction] + split_point
	s2[direction] = cell.start[direction] + split_point

	room_generator.cells.push_back(Cell.new(cell.start, e1))
	room_generator.cells.push_back(Cell.new(s2, cell.end))


func get_split_direction(cell: Cell) -> Utils.Axis:
	var y_split_chance = randi_range(0, 2)
	if (
		(cell.size().y > room_generator.generation_params.min_room_size.y and y_split_chance != 0)
		or (
			cell.size().x <= room_generator.generation_params.min_room_size.x
			&& cell.size().z <= room_generator.generation_params.min_room_size.z
		)
	):
		return Utils.Axis.Y

	if cell.size().x <= room_generator.generation_params.min_room_size.x:
		return Utils.Axis.Z
	if cell.size().z <= room_generator.generation_params.min_room_size.z:
		return Utils.Axis.X

	var split_dir_rand = (
		room_generator.generation_params.long_room_tendency * cell.max_side_length()
	)
	var randomizer = randi_range(-split_dir_rand, split_dir_rand)

	var diff = cell.size().x - cell.size().z
	var randomized_diff = diff + randomizer

	if randomized_diff <= 0:
		return Utils.Axis.Z
	return Utils.Axis.X
