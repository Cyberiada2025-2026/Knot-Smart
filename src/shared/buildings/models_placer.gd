@tool
class_name ModelsPlacer
extends Node

# this is retarded
enum Orientation {
	R0 = 0,  # 0
	R90 = 22,  # 90
	R180 = 10,  # 180
	R270 = 16,  # 270
}

@export var mesh_library: MeshLibrary
@export var floor_grid: GridMap
@export var wall_x_grid: GridMap
@export var wall_z_grid: GridMap

var room_generator: RoomGenerator


func place_entrance(c: BorderInfo):
	var entrance_location = c.door_position

	if c.cell.size_y() == 0:
		floor_grid.set_cell_item(
			entrance_location, mesh_library.find_item_by_name("Hole"), Orientation.R0
		)
	elif c.cell.size_x() == 0:
		wall_z_grid.set_cell_item(
			entrance_location, mesh_library.find_item_by_name("Door"), Orientation.R270
		)
	else:
		wall_x_grid.set_cell_item(
			entrance_location, mesh_library.find_item_by_name("Door"), Orientation.R0
		)


func clear_models():
	floor_grid.clear()
	wall_x_grid.clear()
	wall_z_grid.clear()


func place_models(_room_generator: RoomGenerator):
	room_generator = _room_generator

	clear_models()
	spawn_walls_between_rooms()
	spawn_building_border_walls()


func concat(a: Array, e: Array) -> Array:
	a += e
	return a


func spawn_building_border_walls():
	var all_borders = (
		room_generator.cells.map(func(c): return c.get_all_borders()).reduce(concat, [])
	)
	var all_wall_locations_x = (
		all_borders
		. filter(func(b): return b.cell.size_z() == 0)
		. map(func(b): return b.model_locations())
		. reduce(concat, [])
		. map(func(l): return [l, Orientation.R0])
	)
	var all_wall_locations_z = (
		all_borders
		. filter(func(b): return b.cell.size_x() == 0)
		. map(func(b): return b.model_locations())
		. reduce(concat, [])
		. map(func(l): return [l, Orientation.R270])
	)
	var all_wall_locations = all_wall_locations_x + all_wall_locations_z

	var neighbor_locations_x = (
		room_generator
		. neighbors
		. filter(func(n): return n.cell.size_z() == 0)
		. map(func(n): return n.model_locations())
		. reduce(concat, [])
		. map(func(l): return [l, Orientation.R0])
	)
	var neighbor_locations_z = (
		room_generator
		. neighbors
		. filter(func(n): return n.cell.size_x() == 0)
		. map(func(n): return n.model_locations())
		. reduce(concat, [])
		. map(func(l): return [l, Orientation.R270])
	)
	var neighbor_locations = neighbor_locations_x + neighbor_locations_z

	var outside_wall_locations: Array = all_wall_locations.filter(
		func(l): return not l in neighbor_locations
	)
	var outside_door_locations: Array = outside_wall_locations.filter(func(l): return l[0].y == 0)

	place_windows(outside_wall_locations)
	place_entrance_doors(outside_door_locations)


func place_model_count_in_locations(locations: Array, model_id: int, count: int):
	for i in count:
		var l = locations.pick_random()

		if l[1] == Orientation.R0:
			if wall_x_grid.get_cell_item(l[0]) == model_id:
				i -= 1
				continue
			wall_x_grid.set_cell_item(l[0], model_id, Orientation.R0)
		else:
			if wall_z_grid.get_cell_item(l[0]) == model_id:
				i -= 1
				continue
			wall_z_grid.set_cell_item(l[0], model_id, Orientation.R270)


func place_windows(outside_wall_locations: Array):
	var window_count = floor(
		outside_wall_locations.size() * room_generator.generation_params.window_percentage
	)
	place_model_count_in_locations(
		outside_wall_locations, mesh_library.find_item_by_name("Window"), window_count
	)


func place_entrance_doors(outside_door_locations: Array):
	place_model_count_in_locations(
		outside_door_locations,
		mesh_library.find_item_by_name("Door"),
		room_generator.generation_params.outside_door_count
	)


func spawn_walls_between_rooms():
	for n in room_generator.neighbors.filter(func(n): return n.is_open):
		place_entrance(n)

	for c in room_generator.cells:
		var borders = c.get_all_borders()
		for n in borders:
			var locations = n.model_locations()
			for l in locations:
				if n.cell.size_y() == 0 and floor_grid.get_cell_item(l) == -1:
					floor_grid.set_cell_item(
						l, mesh_library.find_item_by_name("Floor"), Orientation.R0
					)
				elif n.cell.size_x() == 0 and wall_z_grid.get_cell_item(l) == -1:
					wall_z_grid.set_cell_item(
						l, mesh_library.find_item_by_name("Wall"), Orientation.R270
					)
				elif n.cell.size_z() == 0 and wall_x_grid.get_cell_item(l) == -1:
					wall_x_grid.set_cell_item(
						l, mesh_library.find_item_by_name("Wall"), Orientation.R0
					)
