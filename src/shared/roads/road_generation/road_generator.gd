@tool
class_name RoadGenerator
extends Node

@export var generation_params: RoadGenerationParams = RoadGenerationParams.new()

# testing flags are splitted into different categories to ensure easy debugging
@export_group("testing")
@export var debug_visualization: bool:
	set(value):
		debug_visualization = value
		DebugDraw3D.clear_all()
		

@export var log_generation_steps: bool
@export_tool_button("Log Generated Map") var log_generated_map_to_console = _print_to_console.bind("type")
@export_tool_button("Log ID's") var log_id_to_console = _print_to_console.bind("id")
@export_tool_button("Log Rotations") var log_rotations_to_console = _print_to_console.bind("rotation")

@export_group("")
@export_tool_button("Generate roads") var generate_action = generate_roads.bind(Dictionary())

var _blueprint: Dictionary
var _map_size: int
var _final_spots: Array[Spot] = []

## Indicates creation of any road generator [br][br]
## Used by some parameters to properly enable custom setters
static var loaded: bool = false

func _ready():
	loaded = true
			
			
#####################################################
#                 GENERATOR FUNCTIONS               #
#####################################################


## Get coordinates of all points located between start and end positions
func _get_area_positions_array(start: Vector2i, end: Vector2i) -> Array:
	var coordinates: Array[Vector2i]
	for x in range(start.x, end.x + 1):
		for y in range(start.y, end.y + 1):
			coordinates.push_back(Vector2i(x, y))
	return coordinates
	

func _is_valid_tile(position: Vector2i, axis: int):
	return (
			(
				axis == Utils.Axis2.X
				and _blueprint[position]["can_place"] == "slope_x"
			)
			or (
				axis == Utils.Axis2.Y
				and _blueprint[position]["can_place"] == "slope_z"
			)
			or _blueprint[position]["can_place"] == "any"
		)
	
	
## Splits spot into 2 smaller ones if possible
func _split_spot(spot: Spot, area: LimitterArea, axis: int, spots: Array) -> bool:
	if spot.size()[axis] <= area.max_spot_size[axis]:
		return false
		
	var split_point = randi_range(
		area.min_spot_size[axis],
		spot.size()[axis] - area.min_spot_size[axis]
	)
	
	var e1: Vector2i = spot.end
	var s2: Vector2i = spot.start
	e1[axis] = spot.start[axis] + split_point
	s2[axis] = spot.start[axis] + split_point
	
	# avoid placing streets on incorrect slopes and terrain corners
	for position in _get_area_positions_array(s2, e1):
		if not _is_valid_tile(position, axis):
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
	
	
func _find_overlap_with_area(area: LimitterArea, spot: Spot):
	return area.spot_limit_area.overlaps(spot)
	
	
## Move spots' start 1 tile forward
func _move_spot_start(spots: Array[Spot]):
	for axis in Utils.Axis2.values():
		for spot in spots:
			if spot.start[axis] != 0:
				spot.start[axis] += 1
	
	
func _generate_spots():
	var spots: Array[Spot] = []
	
	# create initial rectangle spot that will be divided into smaller ones
	spots.push_back(Spot.new(Vector2i(0, 0), Vector2i(_map_size - 1, _map_size - 1)))
	
	var steps_success: int = 0
	var steps_all: int = 0
	
	# splitting rectangles until they reach proper size
	while not spots.is_empty() and steps_all < generation_params.generation_steps_limit:
		steps_all += 1
		var curr_pos: int = randi() % len(spots)
		var curr_spot: Spot = spots[curr_pos]
		var area_idx = generation_params.generation_areas.find_custom(_find_overlap_with_area.bind(curr_spot))
		var area = generation_params.generation_areas[area_idx]
			
		# action decides whether we are splitting x or y direction
		var axis = Utils.Axis2.values().pick_random()
		
		if _split_spot(curr_spot, area, axis, spots):
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
	
	if not spots.is_empty():
		if log_generation_steps:
			print("full splits failed for ", spots.size(), " spots, moving them to final array")
		while not spots.is_empty():
			if _is_spot_touching_map_bounds(spots.back()):
				spots.pop_back()
			else:
				_final_spots.push_back(spots.pop_back())
	
	if log_generation_steps:
		print("Roads generated, road generation success steps: ", steps_success, " all: ", steps_all)


#####################################################
#              MAIN GENERATION FUNCTION             #
#####################################################


## Generate basic road map [br][br]
## Changes tile "type" to "road" from "empty" when places road [br][br]
## Returns false on error
func generate_roads(blueprint: Dictionary) -> bool:
	if log_generation_steps:
		print("start road generation!")
		
	# clear previous generation results
	_final_spots.clear()
	
	_map_size = generation_params.map_size
	
	if blueprint.is_empty():
		# will be replaced by default creation from blueprint class
		_create_default_blueprint()
	else:
		_blueprint = blueprint	
	
	generation_params.prepare_generation_areas()
	_generate_spots()
	
	for spot in _final_spots:
		spot.cast_on_blueprint(_blueprint)
	
	# adjust spot sizes to avoid intersection with roads when they will be exported
	_move_spot_start(_final_spots)
	
	# later will be splitted and used outside of road generator
	var autotiler: RoadAutotile = RoadAutotile.new()
	
	if not autotiler.autotile_roads(_blueprint, _map_size):
		return false
		
	if debug_visualization:
		_visualize()
	if log_generation_steps:
		print("finished full generation!\n")
		
	return true
	

#####################################################
#             DEBUG AND TESTING FUNCTIONS           #
#####################################################


func _create_default_blueprint() -> void:
	for x in _map_size:
		for y in _map_size:
			var coord: Vector2i = Vector2i(x, y)
			_blueprint[coord]= {
				"height": 0.0,
				"type": "empty",
				"can_place": "any",
			}


## Printing blueprint map data from given dictionary key for debug
func _print_to_console(key: String) -> void:
	if _blueprint.is_empty():
		return
	print("printing '", key, "':")
		
	for y in _map_size:
		var output: String = ""
		for x in _map_size:
			if _blueprint[Vector2i(x, y)]["type"] == "road":
				if key == "type":
					output += " R"
				if key == "rotation":
					output += " " + str(_blueprint[Vector2i(x, y)][key] / 90)
				if key == "id":
					if _blueprint[Vector2i(x, y)][key] >= 0 and _blueprint[Vector2i(x, y)][key] < 10:
						output += " " + str(_blueprint[Vector2i(x, y)][key])
					else:
						output += str(_blueprint[Vector2i(x, y)][key])
			else:
				output += "  "
		print(output)
		

## Simple test visualization
func _visualize() -> void:
	DebugDraw3D.clear_all()
	await get_tree().process_frame
		
	# visualize spots
	for spot in _final_spots:
		DebugDraw3D.draw_box(
			Vector3(spot.start.x, 0, spot.start.y),
			Quaternion.IDENTITY, 
			Vector3(spot.size().x, 1, spot.size().y), 
			Color(randf(), randf(), randf(), 1.0), 
			false,
			INF
		)
	
	# visualize roads
	for x in _map_size:
		for z in _map_size:
			if _blueprint[Vector2i(x, z)]["type"] == "road":
				DebugDraw3D.draw_box(
					Vector3(x, 0, z),
					Quaternion.IDENTITY, 
					Vector3(1, 0.01, 1),
					Color(1.0, 1.0, 1.0, 1.0),
					false,
					INF
				)
