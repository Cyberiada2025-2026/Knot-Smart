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
@export var gridmaps: Array[GridMap]

var room_generator: RoomGenerator


func place_entrance(c: BorderInfo):
	var entrance_location = c.door_position

	if c.cell.size().y == 0:
		gridmaps[1].set_cell_item(
			entrance_location, mesh_library.find_item_by_name("Hole"), Orientation.R0
		)
	elif c.cell.size().x == 0:
		gridmaps[0].set_cell_item(
			entrance_location, mesh_library.find_item_by_name("Door"), Orientation.R270
		)
	else:
		gridmaps[2].set_cell_item(
			entrance_location, mesh_library.find_item_by_name("Door"), Orientation.R0
		)


func clear_models():
	for grid in gridmaps:
		grid.clear()


func place_models(_room_generator: RoomGenerator):
	room_generator = _room_generator

	clear_models()
	spawn_walls_between_rooms()
	spawn_building_border_walls()


func concat(a: Array, e: Array) -> Array:
	a += e
	return a


func get_wall_locations(borders: Array, dir: Utils.Axis, orientation: ModelsPlacer.Orientation) -> Array:
	return (borders
		. filter(func(b): return b.cell.size()[dir] == 0)
		. map(func(b): return b.model_locations())
		. reduce(concat, [])
		. map(func(l): return [l, orientation])
	)

func spawn_building_border_walls():
	var all_borders = (
		room_generator.cells.map(func(c): return c.get_all_borders()).reduce(concat, [])
	)
	var all_wall_locations_x = get_wall_locations(all_borders, Utils.Axis.Z, orientations[Utils.Axis.Z])
	var all_wall_locations_z = get_wall_locations(all_borders, Utils.Axis.X, orientations[Utils.Axis.X])

	var all_wall_locations = all_wall_locations_x + all_wall_locations_z

	var neighbor_locations_x = get_wall_locations(room_generator.neighbors, Utils.Axis.Z, orientations[Utils.Axis.Z])
	var neighbor_locations_z = get_wall_locations(room_generator.neighbors, Utils.Axis.X, orientations[Utils.Axis.X])

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
		
		var axis = Utils.Axis.Z if l[1] == Orientation.R0 else Utils.Axis.X

		if gridmaps[axis].get_cell_item(l[0]) == model_id:
			i -= 1
		else:
			gridmaps[axis].set_cell_item(l[0], model_id, orientations[axis])



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

func _ready() -> void:
	mesh_dict = { 
		str(Utils.Axis.X) + "_open": mesh_library.find_item_by_name("Door"),
		str(Utils.Axis.X) + "_closed": mesh_library.find_item_by_name("Wall"),
		str(Utils.Axis.Y) + "_open": mesh_library.find_item_by_name("Hole"),
		str(Utils.Axis.Y) + "_closed": mesh_library.find_item_by_name("Floor"),
		str(Utils.Axis.Z) + "_open": mesh_library.find_item_by_name("Door"),
		str(Utils.Axis.Z) + "_closed": mesh_library.find_item_by_name("Wall")
	}

var mesh_dict: Dictionary[String, int]

var orientations: Dictionary[Utils.Axis, ModelsPlacer.Orientation] = {
	Utils.Axis.X: Orientation.R270,
	Utils.Axis.Y: Orientation.R0,
	Utils.Axis.Z: Orientation.R0,
}

func spawn_walls_between_rooms():
	for n in room_generator.neighbors.filter(func(n): return n.is_open):
		place_entrance(n)

	for c in room_generator.cells:
		for n in c.get_all_borders():
			for l in n.model_locations():
				if n.cell.size().y == 0 and gridmaps[1].get_cell_item(l) == -1:
					gridmaps[1].set_cell_item(
						l, mesh_library.find_item_by_name("Floor"), Orientation.R0
					)
				elif n.cell.size().x == 0 and gridmaps[0].get_cell_item(l) == -1:
					gridmaps[0].set_cell_item(
						l, mesh_library.find_item_by_name("Wall"), Orientation.R270
					)
				elif n.cell.size().z == 0 and gridmaps[2].get_cell_item(l) == -1:
					gridmaps[2].set_cell_item(
						l, mesh_library.find_item_by_name("Wall"), Orientation.R0
					)
