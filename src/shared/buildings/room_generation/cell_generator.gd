@tool
class_name CellGenerator
extends Node

var building_generator: BuildingGenerator


func generate_cells(_building_generator: BuildingGenerator) -> void:
	building_generator = _building_generator
	building_generator.cells = building_generator.initial_cells.duplicate_deep()

	split_cells()


func split_cells():
	if building_generator.cells.size() == 0:
		return
	while true:
		var cell = pop_next_cell()
		if cell == null:
			break

		split(cell)


func pop_next_cell() -> Cell:
	var cell_idx = building_generator.cells.find_custom(
		func(c): return c.is_larger_than(building_generator.room_generation_params.max_room_size)
	)
	return building_generator.cells.pop_at(cell_idx) if cell_idx != -1 else null


func split(cell: Cell) -> void:
	var direction = self.get_split_direction(cell)

	var e1: Vector3i = cell.end
	var s2: Vector3i = cell.start

	var split_point = randi_range(
		building_generator.room_generation_params.min_room_size[direction],
		cell.size()[direction] - building_generator.room_generation_params.min_room_size[direction]
	)
	e1[direction] = cell.start[direction] + split_point
	s2[direction] = cell.start[direction] + split_point

	building_generator.cells.push_back(Cell.new(cell.start, e1))
	building_generator.cells.push_back(Cell.new(s2, cell.end))


func get_split_direction(cell: Cell) -> Utils.Axis:
	var is_smaller_than_min_x = (
		cell.size().x <= building_generator.room_generation_params.min_room_size.x
	)
	var is_smaller_than_min_z = (
		cell.size().z <= building_generator.room_generation_params.min_room_size.z
	)

	var y_split_chance = randi_range(0, 2)
	if (
		(
			cell.size().y > building_generator.room_generation_params.min_room_size.y
			and y_split_chance != 0
		)
		or (is_smaller_than_min_x && is_smaller_than_min_z)
	):
		return Utils.Axis.Y

	if is_smaller_than_min_x:
		return Utils.Axis.Z
	if is_smaller_than_min_z:
		return Utils.Axis.X

	var split_dir_rand = (
		building_generator.room_generation_params.long_room_tendency * cell.max_side_length()
	)
	var randomizer = randi_range(-split_dir_rand, split_dir_rand)

	var diff = cell.size().x - cell.size().z
	var randomized_diff = diff + randomizer

	return Utils.Axis.Z if randomized_diff <= 0 else Utils.Axis.X
