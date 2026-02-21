@tool
extends Node
class_name RoadBitmask

enum road_id {
	tiling_error = -1,
	empty = 0,  # same value as EMPTY_TILE constant in road generation params
	horizontal_straight,
	vertical_straight,
	T_down, 
	T_left,
	T_up,
	T_right,
	crossroad,
	turn_right_to_down,
	turn_left_to_down,
	turn_left_to_up,
	turn_right_to_up
}

# straight highways are splitted into 2 different ID's for every side
# "connected" represents highway connected with normal road
enum highway_id {
	horizontal_up = 12,
	horizontal_up_connected,
	vertical_right,
	vertical_right_connected,
	horizontal_down,
	horizontal_down_connected,
	vertical_left,
	vertical_left_connected,

	# from now location description is related to position in 2x2 highway square and not to connections
	crossroad_up_left,  # crossroad tiles are used for highways intersection
	crossroad_up_right,
	crossroad_down_right,
	crossroad_down_left,
	corner_up_left,  # corners are used at map borders to ensure proper visuals
	corner_up_left_connected_left,
	corner_up_left_connected_up,
	corner_up_left_connected_up_and_left,
	corner_up_right,
	corner_up_right_connected_up,
	corner_up_right_connected_right,
	corner_up_right_connected_right_and_up,
	corner_down_right,
	corner_down_right_connected_right,
	corner_down_right_connected_down,
	corner_down_right_connected_down_and_right,
	corner_down_left,
	corner_down_left_connected_down,
	corner_down_left_connected_left,
	corner_down_left_connected_left_and_down,
	
	diagonal_down_left_to_up_right,
	diagonal_down_right_to_up_left,
}

# connections for autotiling
enum {
	EMPTY,
	ROAD,
	ANY
}

## dictionary of base tiles which are used to create all other road tiles
# values represent 3x3 grid with targeted tile at center
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
	highway_id.horizontal_up: [ANY, EMPTY, ANY,
								ROAD, ROAD, ROAD,
								ROAD, ROAD, ROAD],
	highway_id.horizontal_up_connected: [EMPTY, ROAD, EMPTY,
										ROAD, ROAD, ROAD,
										ROAD, ROAD, ROAD],
	highway_id.crossroad_up_left: [EMPTY, ROAD, ROAD,
								ROAD, ROAD, ROAD,
								ROAD, ROAD, ROAD],
	highway_id.corner_up_left: [EMPTY, EMPTY, EMPTY,
								EMPTY, ROAD, ROAD,
								EMPTY, ROAD, ROAD],
	highway_id.corner_up_left_connected_left: [ANY, EMPTY, ANY,
											ROAD, ROAD, ROAD,
											EMPTY, ROAD, ROAD],
	highway_id.corner_up_left_connected_up: [ANY, ROAD, EMPTY,
											EMPTY, ROAD, ROAD,
											ANY, ROAD, ROAD],
	highway_id.corner_up_left_connected_up_and_left: [EMPTY, ROAD, EMPTY,
													ROAD, ROAD, ROAD,
													EMPTY, ROAD, ROAD],
	highway_id.diagonal_down_left_to_up_right: [EMPTY, ROAD, ROAD,
												ROAD, ROAD, ROAD,
												ROAD, ROAD, EMPTY],
}

# for every id is assigned array of neighbour connections from base tiles
# !important! use only values from BASE_TILES dictionary with different rotations to avoid problems
static var _road_connections_by_id: Dictionary = {
	road_id.horizontal_straight: BASE_TILES[road_id.horizontal_straight],
	road_id.vertical_straight: _rotate(90, BASE_TILES[road_id.horizontal_straight]),
	road_id.T_down: BASE_TILES[road_id.T_down],
	road_id.T_left: _rotate(90, BASE_TILES[road_id.T_down]),
	road_id.T_up: _rotate(180, BASE_TILES[road_id.T_down]),
	road_id.T_right: _rotate(270, BASE_TILES[road_id.T_down]),
	road_id.crossroad: BASE_TILES[road_id.crossroad],
	road_id.turn_right_to_down: BASE_TILES[road_id.turn_right_to_down],
	road_id.turn_left_to_down: _rotate(90, BASE_TILES[road_id.turn_right_to_down]),
	road_id.turn_left_to_up: _rotate(180, BASE_TILES[road_id.turn_right_to_down]),
	road_id.turn_right_to_up: _rotate(270, BASE_TILES[road_id.turn_right_to_down]),

	highway_id.horizontal_up: BASE_TILES[highway_id.horizontal_up],
	highway_id.horizontal_up_connected: BASE_TILES[highway_id.horizontal_up_connected],
	highway_id.vertical_right: _rotate(90, BASE_TILES[highway_id.horizontal_up]),
	highway_id.vertical_right_connected: _rotate(90, BASE_TILES[highway_id.horizontal_up_connected]),

	# it's better to mirror these instead of rotating but at this case result is same
	highway_id.horizontal_down: _rotate(180, BASE_TILES[highway_id.horizontal_up]),
	highway_id.horizontal_down_connected: _rotate(180, BASE_TILES[highway_id.horizontal_up_connected]),
	highway_id.vertical_left: _rotate(270, BASE_TILES[highway_id.horizontal_up]),
	highway_id.vertical_left_connected: _rotate(270, BASE_TILES[highway_id.horizontal_up_connected]),
	
	highway_id.crossroad_up_left: BASE_TILES[highway_id.crossroad_up_left], 
	highway_id.crossroad_up_right: _rotate(90, BASE_TILES[highway_id.crossroad_up_left]),
	highway_id.crossroad_down_right: _rotate(180, BASE_TILES[highway_id.crossroad_up_left]),
	highway_id.crossroad_down_left: _rotate(270, BASE_TILES[highway_id.crossroad_up_left]),
	
	highway_id.corner_up_left: BASE_TILES[highway_id.corner_up_left], 
	highway_id.corner_up_left_connected_left: BASE_TILES[highway_id.corner_up_left_connected_left],
	highway_id.corner_up_left_connected_up: BASE_TILES[highway_id.corner_up_left_connected_up],
	highway_id.corner_up_left_connected_up_and_left: BASE_TILES[highway_id.corner_up_left_connected_up_and_left],
	
	highway_id.corner_up_right: _rotate(90, BASE_TILES[highway_id.corner_up_left]),
	highway_id.corner_up_right_connected_up: _rotate(90, BASE_TILES[highway_id.corner_up_left_connected_left]),
	highway_id.corner_up_right_connected_right: _rotate(90, BASE_TILES[highway_id.corner_up_left_connected_up]),
	highway_id.corner_up_right_connected_right_and_up: _rotate(90, BASE_TILES[highway_id.corner_up_left_connected_up_and_left]),
	
	highway_id.corner_down_right: _rotate(180, BASE_TILES[highway_id.corner_up_left]),
	highway_id.corner_down_right_connected_right: _rotate(180, BASE_TILES[highway_id.corner_up_left_connected_left]),
	highway_id.corner_down_right_connected_down: _rotate(180, BASE_TILES[highway_id.corner_up_left_connected_up]),
	highway_id.corner_down_right_connected_down_and_right: _rotate(180, BASE_TILES[highway_id.corner_up_left_connected_up_and_left]),
	
	highway_id.corner_down_left: _rotate(270, BASE_TILES[highway_id.corner_up_left]),
	highway_id.corner_down_left_connected_down: _rotate(270, BASE_TILES[highway_id.corner_up_left_connected_left]),
	highway_id.corner_down_left_connected_left: _rotate(270, BASE_TILES[highway_id.corner_up_left_connected_up]),
	highway_id.corner_down_left_connected_left_and_down: _rotate(270, BASE_TILES[highway_id.corner_up_left_connected_up_and_left]),

	highway_id.diagonal_down_left_to_up_right: BASE_TILES[highway_id.diagonal_down_left_to_up_right],
	highway_id.diagonal_down_right_to_up_left: _rotate(90, BASE_TILES[highway_id.diagonal_down_left_to_up_right]),
}

# all neighbour arrays are 3x3 but are represented as singe dimension array
const NEIGHBOUR_ARRAY_SIZE: int = 9
static var _road_id_bitmask: Dictionary = {}

## simple clockwise neighbour array rotation function, returns copy of provided array
static func _rotate(angle: int, array: Array):
	if array.size() != NEIGHBOUR_ARRAY_SIZE:
		printerr("found wrong-sized neighbour array in autotiling")
		return
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

	
## converts array into integer and creates bitmask dictionary key connected to it's tile ID[br]
## recurrent conversion allows creating proper values whe ANY connection type appears
static func _convert_array_to_bitmask(
	array: Array, id: int, bitmask_result: int = 0, current_position: int = 0
	):
	if current_position < NEIGHBOUR_ARRAY_SIZE :
		if array[current_position] == ROAD:
			bitmask_result += 1 << current_position
			_convert_array_to_bitmask(array, id, bitmask_result, current_position + 1)
		elif array[current_position] == EMPTY:
			_convert_array_to_bitmask(array, id, bitmask_result, current_position + 1)
		elif array[current_position] == ANY:
			# ANY as EMPTY
			_convert_array_to_bitmask(array, id, bitmask_result, current_position + 1)
			# ANY as ROAD
			bitmask_result += 1 << current_position
			_convert_array_to_bitmask(array, id, bitmask_result, current_position + 1)
		else:
			printerr("wrong data type '", array[current_position], '\' in "BASE_TILES" dictionary')
			return	
	else:
		_road_id_bitmask.set(bitmask_result, id)
		
		
## generate bitmask keys for every road ID to use for autotiling
static func create_bitmask() -> bool:
	if not _road_id_bitmask.is_empty():
		_road_id_bitmask.clear()
		
	for key in _road_connections_by_id:
		if _road_connections_by_id[key].size() != NEIGHBOUR_ARRAY_SIZE:
			printerr("found wrong-sized neighbour array in autotiling")
			continue
		_convert_array_to_bitmask(_road_connections_by_id[key], key)
	
	if _road_id_bitmask.is_empty():
		printerr('road bitmask not created, check "_road_connections_by_id" dictionary data')
		return false
	return true
		

static func get_road_id_count():
	return road_id.size() + highway_id.size()
	
	
## converts road connection bitmask into proper autotiled road ID
static func get_road_id_from_bitmask(bitmask_key: int):
	if _road_id_bitmask.is_empty():
		printerr("trying to access road bitmask without creating it...")
		if not create_bitmask():
			return
	if _road_id_bitmask.has(bitmask_key):
		return _road_id_bitmask[bitmask_key]
	else:
		printerr("bitmask key not found:", bitmask_key)
		return -1
