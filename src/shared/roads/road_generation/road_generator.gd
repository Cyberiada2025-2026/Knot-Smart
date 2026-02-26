@tool
class_name RoadGenerator
extends Node

@export var generation_params: RoadGenerationParams

@export_group("testing")
@export var create_visualization: bool
@export var visualization_duration: int = 10
@export var log_generated_map_to_console: bool
@export var log_id_to_console: bool
@export var log_rotations_to_console: bool
@export var more_log_messages: bool
@export_tool_button("Test Generation") var generate_action = test

var _blueprint: Dictionary
var _map_size: int
var _final_spots: Array[Spot] = []
		
			
#####################################################
#                 GENERATOR FUNCTIONS               #
#####################################################


## get coordinates of all points located between start and end positions
func _get_area_positions_array(start: Vector2i, end: Vector2i) -> Array:
	var coordinates: Array[Vector2i]
	for x in range(start.x, end.x + 1):
		for y in range(start.y, end.y + 1):
			coordinates.push_back(Vector2i(x, y))
	return coordinates
	
	
## splits spot into 2 smaller ones
func _split_spot(spot: Spot, min_spot_size: Vector2i, axis: int, spots: Array) -> bool:
	var split_point = randi_range(
		min_spot_size[axis],
		spot.size()[axis] - min_spot_size[axis]
	)
	
	var e1: Vector2i = spot.end
	var s2: Vector2i = spot.start
	e1[axis] = spot.start[axis] + split_point
	s2[axis] = spot.start[axis] + split_point
	
	# avoid placing streets on incorrect slopes and terrain corners
	for position in _get_area_positions_array(s2, e1):
		if (
			(
				axis == Utils.Axis2.X
				and _blueprint[position]["can_place"] == "slope_z"
			)
			or (
				axis == Utils.Axis2.Y
				and _blueprint[position]["can_place"] == "slope_x"
			)
			or _blueprint[position]["can_place"] == "none"
		):
			return false
	
	var new_spot: Spot = Spot.new(s2, spot.end)
	spot.end = e1
	spots.push_back(new_spot)
	return true
	
	
func _is_spot_correctly_sized(spot: Spot, max_spot_size: Vector2i) -> bool:
	for axis in Utils.Axis2.values():
		if spot.size()[axis] > max_spot_size[axis]:
			return false
	return true
	
	
func _is_spot_touching_map_bounds(spot: Spot) -> bool:
	for axis in Utils.Axis2.values():
		if(
			spot.start[axis] == 0
			or spot.end[axis] ==  _map_size - 1 
		):
			return true
	return false
	
	
## move spots' start 1 tile forward
func _move_spot_start(spots: Array[Spot]):
	for axis in Utils.Axis2.values():
		for spot in spots:
			if spot.start[axis] != 0:
				spot.start[axis] += 1
	
	
func _generate_spots():
	var spots: Array[Spot] = []
	
	# create initial rectangle spot that will be divided into smaller ones
	spots.push_back(Spot.new(Vector2i(0, 0), Vector2i(_map_size - 1, _map_size - 1)))
	
	# splitting rectangles until they reach proper size
	var steps_success: int = 0
	var steps_all: int = 0
	
	# TODO add steps_all limits to params
	while not spots.is_empty() and steps_all < _map_size * _map_size:
		steps_all += 1
		var area_idx: int = 0
		var curr_pos: int = randi() % len(spots)
		var curr_spot: Spot = spots[curr_pos]
		
		while not curr_spot.overlaps(generation_params.generation_areas[area_idx].spot_limit_area):
			area_idx += 1
		var area = generation_params.generation_areas[area_idx]
			
		# action decides whether we are splitting x or y direction
		var axis = Utils.Axis2.values().pick_random()
		
		if curr_spot.size()[axis] > area.max_spot_size[axis]:
			if _split_spot(curr_spot, area.min_spot_size, axis, spots):
				steps_success += 1
			
		if _is_spot_correctly_sized(curr_spot, area.max_spot_size):
			if _is_spot_touching_map_bounds(curr_spot):
				spots.remove_at(curr_pos)
			else:
				_final_spots.push_back(spots.pop_at(curr_pos))
			
		# highways are created by moving all spots's start by 1
		if steps_success == generation_params.highway_generation_split_count:
			_move_spot_start(spots)
			_move_spot_start(_final_spots)
			steps_success += 1
	
	if more_log_messages:
		print("Roads generated, road generation success steps: ", steps_success, " all: ", steps_all)


#####################################################
#              MAIN GENERATION FUNCTION             #
#####################################################


## generate basic road map [br]
## changes tile "type" to "road" from "empty" when places road 
func generate_roads(blueprint: Dictionary):
	
	## clear previous generation results
	_final_spots.clear()
	
	_blueprint = blueprint
	_map_size = generation_params.map_size
	
	generation_params.check_generation_areas()
	_generate_spots()
	
	for spot in _final_spots:
		spot.cast_on_blueprint(_blueprint)
	
	# adjust spot sizes to avoid intersection with roads
	_move_spot_start(_final_spots)
	
	# avoiding extreme amount of error messages if bitmask creation fails
	# and also avoiding modifying export map to return empty export data on error
	var autotiler: RoadAutotile = RoadAutotile.new()
	
	if not autotiler.autotile_roads(_blueprint, _map_size):
		return false
	#
	#_export_data_array()
				
	return true
	

#####################################################
#             DEBUG AND TESTING FUNCTIONS           #
#####################################################


func test() -> void:
	var test_terrain_blueprint: Dictionary
	for x in range(generation_params.map_size):
		for y in range(generation_params.map_size):
			var coord: Vector2i = Vector2i(x, y)
			test_terrain_blueprint[coord]= {
				"height": 0.0,
				"type": "empty",
				"can_place": "any",
			}
	if more_log_messages:
		print("start road generation!")
	
	generate_roads(test_terrain_blueprint)
	
	if log_generated_map_to_console:
		_print_to_console(test_terrain_blueprint, "type")
	if log_id_to_console:
		_print_to_console(test_terrain_blueprint, "id")
	if log_rotations_to_console:
		_print_to_console(test_terrain_blueprint, "rotation")
	if create_visualization:
		_visualize(test_terrain_blueprint)
	if more_log_messages:
		print("finished full generation!\n")
	

## printing blueprint map data from given dictionary key for debug
func _print_to_console(blueprint: Dictionary, key: String) -> void:
	print("printing '", key, "':")
		
	for y in range(_map_size):
		var output: String = ""
		for x in range(_map_size):
			if blueprint[Vector2i(x, y)]["type"] == "road":
				if key == "type" :
					output += " R"
				if key == "rotation" :
					output += " " + str(blueprint[Vector2i(x, y)][key] / 90)
				if key == "id":
					if blueprint[Vector2i(x, y)][key] >= 0 and blueprint[Vector2i(x, y)][key] < 10:
						output += " " + str(blueprint[Vector2i(x, y)][key])
					else: 
						output += str(blueprint[Vector2i(x, y)][key])
			else:
				output += "  "
		print(output)
		

## simple test visualization 
func _visualize(blueprint: Dictionary) -> void:
	DebugDraw3D.clear_all()
	await get_tree().process_frame
		
	if more_log_messages:
		print("creating visualization")
		
	for i in range(len(_final_spots)):
		_final_spots[i].visualize(visualization_duration)
	
	for x in range(_map_size):
		for z in range(_map_size):
			if blueprint[Vector2i(x, z)]["type"] == "road":
				DebugDraw3D.draw_box(
					Vector3(x, 0, z),
					Quaternion.IDENTITY, 
					Vector3(1, 0.01, 1),
					Color(1.0, 1.0, 1.0, 1.0),
					false,
					visualization_duration
				)
