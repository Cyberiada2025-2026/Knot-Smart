@tool
extends Node
class_name RoadAutotile

enum road_id {
	tiling_error = 0,
	horizontal_straight,
	T_down,
	crossroad,
	turn_right_to_down,
	highway_horizontal_up,
	highway_horizontal_up_connected,
	highway_crossroad_up_left,
	highway_corner_up_left,
	highway_corner_up_left_connected_left,
	highway_corner_up_left_connected_up,
	highway_corner_up_left_connected_up_and_left,
	highway_diagonal_down_left_to_up_right,
}

## connections for autotiling
enum {
	EMPTY,
	ROAD,
	ANY
}

## dictionary of base tiles which are used to create all other road tiles [br]
## values represent 3x3 grid with targeted tile at center
# array values should be visually positioned as 3x3 grid to approve readability
const BASE_TILES: Dictionary = {
	road_id.horizontal_straight: [ANY, EMPTY, ANY,
								ROAD, ROAD, ROAD,
								ANY, EMPTY, ANY],
	road_id.T_down: [ANY, EMPTY, ANY,
					ROAD, ROAD, ROAD,
					EMPTY, ROAD, EMPTY],
	road_id.crossroad: [EMPTY, ROAD, EMPTY,
						ROAD, ROAD, ROAD,
						EMPTY, ROAD, EMPTY],
	road_id.turn_right_to_down: [EMPTY, EMPTY, ANY,
								EMPTY, ROAD, ROAD,
								ANY, ROAD, EMPTY],
	road_id.highway_horizontal_up: [ANY, EMPTY, ANY,
									ROAD, ROAD, ROAD,
									ROAD, ROAD, ROAD],
	road_id.highway_horizontal_up_connected: [EMPTY, ROAD, EMPTY,
											ROAD, ROAD, ROAD,
											ROAD, ROAD, ROAD],
	road_id.highway_crossroad_up_left: [EMPTY, ROAD, ROAD,
										ROAD, ROAD, ROAD,
										ROAD, ROAD, ROAD],
	road_id.highway_corner_up_left: [EMPTY, EMPTY, EMPTY,
									EMPTY, ROAD, ROAD,
									EMPTY, ROAD, ROAD],
	road_id.highway_corner_up_left_connected_left: [ANY, EMPTY, ANY,
													ROAD, ROAD, ROAD,
													EMPTY, ROAD, ROAD],
	road_id.highway_corner_up_left_connected_up: [ANY, ROAD, EMPTY,
												EMPTY, ROAD, ROAD,
												ANY, ROAD, ROAD],
	road_id.highway_corner_up_left_connected_up_and_left: [EMPTY, ROAD, EMPTY,
														ROAD, ROAD, ROAD,
														EMPTY, ROAD, ROAD],
	road_id.highway_diagonal_down_left_to_up_right: [EMPTY, ROAD, ROAD,
													ROAD, ROAD, ROAD,
													ROAD, ROAD, EMPTY],
}

# all neighbour arrays are 3x3 but are represented as singe dimension array
const NEIGHBOUR_ARRAY_SIZE: int = 9
var _road_id_bitmask: Dictionary = {}

## simple clockwise neighbour array rotation function, returns copy of provided array
# I have no idea how to make this with array.map, pls help
static func _rotate_array(angle: int, array: Array):
	# avoid editing original array
	array = array.duplicate()
	
	while angle > 0:
		var result: Array
		result.resize(NEIGHBOUR_ARRAY_SIZE)
		for i in range(array.size()):
			result[(i % 3 + 1) * 3 - 1 - int(i / 3.0)] = array[i] 
		array = result
		angle -= 90
	return array


## converts array into integer and creates bitmask dictionary key connected to it's tile data [br]
## recurrent conversion allows creating proper values whe ANY connection type appears
func _convert_array_to_bitmask(
	array: Array, data: Dictionary, bitmask_result: int = 0, current_position: int = 0
	):
	if current_position < NEIGHBOUR_ARRAY_SIZE :
		if array[current_position] == ROAD:
			bitmask_result += 1 << current_position
			_convert_array_to_bitmask(array, data, bitmask_result, current_position + 1)
		elif array[current_position] == EMPTY:
			_convert_array_to_bitmask(array, data, bitmask_result, current_position + 1)
		elif array[current_position] == ANY:
			# ANY as EMPTY
			_convert_array_to_bitmask(array, data, bitmask_result, current_position + 1)
			# ANY as ROAD
			bitmask_result += 1 << current_position
			_convert_array_to_bitmask(array, data, bitmask_result, current_position + 1)
		else:
			printerr("wrong data type '", array[current_position], '\' in "BASE_TILES" dictionary')
			return	
	elif not _road_id_bitmask.has(bitmask_result):
		_road_id_bitmask.set(bitmask_result, data)


## create bitmasks for all possible positions for single road tile id [br]
## and write them to bitmask dictionary
func _add_to_bitmask(id: int):
	var neighbour_tiles: Array = BASE_TILES[id]
	if neighbour_tiles.size() != NEIGHBOUR_ARRAY_SIZE:
		printerr("found wrong-sized neighbour array in autotiling")
		return
	for angle in range(0, 360, 90):
		var data: = {
			"id": id, 
			"rotation": angle
		}
		_convert_array_to_bitmask(_rotate_array(angle, neighbour_tiles), data)
		
		
## generate bitmask keys for every road ID to use for autotiling
func _create_bitmask() -> bool:
	_road_id_bitmask.clear()
	
	# add every road id to bitmask dictionary
	for id in road_id:
		# tiling error shouldn't be added to bitmask because there's no data for it
		if id != "tiling_error":
			_add_to_bitmask(road_id[id])

	if _road_id_bitmask.is_empty():
		printerr('road bitmask not created, check "_road_connections_by_id" dictionary data')
		return false
	return true
	
	
func _get_tile_connections_bitmask(position: Vector2i, blueprint: Dictionary):
	var bitmask: int = 0
	var i: int = 0
	for y in range(position.y - 1, position.y + 2):
		for x in range(position.x - 1, position.x + 2):
			if blueprint.has(Vector2i(x, y)) and blueprint[Vector2i(x, y)]["type"] == "road":
				bitmask += 1 << i
			i += 1
	return bitmask
	
	
## converts road connection bitmask into proper autotiled road ID
func _get_road_data_from_bitmask(bitmask_key: int) -> Dictionary:
	if _road_id_bitmask.has(bitmask_key):
		return _road_id_bitmask[bitmask_key]
	else:
		printerr("bitmask key not found:", bitmask_key)
		return {
			"id": road_id.tiling_error, 
			"rotation": 0
		}
		
		
## generate road tile ID's and rotations and write them to blueprint
func autotile_roads(blueprint: Dictionary, map_size: int) -> bool:
	if not _create_bitmask():
		printerr("failed creating bitmask, autotile was skipped")
		return false
		
	for x in range(map_size):
		for y in range(map_size):
			if blueprint[Vector2i(x, y)]["type"] == "road":
				var bitmask_key = _get_tile_connections_bitmask(Vector2i(x, y), blueprint)
				var data: Dictionary = _get_road_data_from_bitmask(bitmask_key)
				blueprint[Vector2i(x, y)]["id"]  = data["id"]
				blueprint[Vector2i(x, y)]["rotation"]  = data["rotation"]
	return true
