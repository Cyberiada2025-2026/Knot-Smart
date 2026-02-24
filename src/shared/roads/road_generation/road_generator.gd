@tool
class_name RoadGenerator
extends Node

@export var generation_params: RoadGenerationParams

@export_group("testing")
@export var visualization_container: Node3D
@export var create_visualization: bool
@export var log_generated_map_to_console: bool
@export var log_id_to_console: bool
@export var log_rotations_to_console: bool
@export var more_log_messages: bool
@export_tool_button("Test Generation") var generate_action = test
@export_tool_button("Clear Visualization") var clear_action = clear_test_visualization

var _blueprint: Dictionary
var _map_size: int
var _final_spots: Array[Spot] = []
		
			
#####################################################
#                 GENERATOR FUNCTIONS               #
#####################################################

		
func _generate_spots():
	var spots: Array[Spot] = []
	
	# create initial rectangle spot that will be divided into smaller ones
	spots.push_back(Spot.new(Vector2i(0, 0), Vector2i(_map_size - 1, _map_size - 1)))
	
	# splitting rectangles until they reach proper size
	var steps: int = 0
	while !spots.is_empty():
		var area: int = 0
		var current: int = randi() % len(spots)
		
		while not spots[current].overlaps(generation_params.generation_areas[area].spot_limit_area):
			area += 1
			
		# action decides whether we are splitting x or y direction
		var action = randi() % 2
		
		if (
			spots[current].size().x > generation_params.generation_areas[area].max_spot_size.x 
			and action == 0
		):
			spots.push_back(spots[current].split_x(generation_params.generation_areas[area].min_spot_size))
			steps += 1
		
		if (
			spots[current].size().y > generation_params.generation_areas[area].max_spot_size.y
			and action == 1
		):
			spots.push_back(spots[current].split_y(generation_params.generation_areas[area].min_spot_size))
			steps += 1
			
		# stop splitting spot if it's proper sized and move it to output
		# also remove spots close to map border
		if (
			spots[current].size().x <= generation_params.generation_areas[area].max_spot_size.x 
			and spots[current].size().y <= generation_params.generation_areas[area].max_spot_size.y
		):
			if (
				spots[current].start.x != 0 
				and spots[current].start.y != 0 
				and spots[current].end.x != _map_size - 1 
				and spots[current].end.y != _map_size - 1
			):
				_final_spots.push_back(spots.pop_at(current))
			else:
				spots.pop_at(current)
			
		# main streets, all spots are moved 1 tile forward to create double roads when casting to map
		if steps == generation_params.highway_generation_split_count:
			for i in range(len(_final_spots)):
				_final_spots[i].start.x += 1
				_final_spots[i].start.y += 1
					
			for i in range(len(spots)):
				# avoid rectangles close to map border
				if spots[i].start.x != 0:
					spots[i].start.x += 1
				if spots[i].start.y != 0:
					spots[i].start.y += 1
			steps += 1
	
	for spot in _final_spots:
		spot.cast_on_blueprint(_blueprint)
	
	if more_log_messages:
		print("Roads generated, road generation steps: ", steps)


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
	
	## avoiding extreme amount of error messages if bitmask creation fails
	## and also avoiding modifying export map to return empty export data on error
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
	clear_test_visualization()
	
	if more_log_messages:
		print("creating visualization")
		
	for i in range(len(_final_spots)):
		_final_spots[i].visualize(visualization_container, str(i))
	
	for x in range(_map_size):
		for y in range(_map_size):
			if str(blueprint[Vector2i(x, y)]["type"]) == "road":
				var road = MeshInstance3D.new()
				road.mesh = BoxMesh.new()
				road.mesh.size = Vector3(1, 1, 1)
				road.position = Vector3(x + 0.5, 2, y + 0.5)
				road.name = "road %s %s" % [x, y]

				var material = StandardMaterial3D.new()
				material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
				road.mesh.material = material
				
				visualization_container.add_child(road)
				road.owner = visualization_container.owner
				

## delete all children from visualization container
func clear_test_visualization() -> void:
	if more_log_messages:
		print("clearing last visualization")
	for n in visualization_container.get_children():
		visualization_container.remove_child(n)
