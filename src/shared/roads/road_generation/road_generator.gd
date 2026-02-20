@tool
class_name RoadGenerator
extends Node

@export var generation_params: RoadGenerationParams

@export_group("testing")
@export var visualization_container: Node3D
@export var test_map_size: Vector2i = Vector2i(51, 51)
@export var create_visualization: bool
@export var log_generated_map_to_console: bool
@export var log_export_map_to_console: bool
@export var more_log_messages: bool
@export_tool_button("Test Generation") var generate_action = test
@export_tool_button("Clear Visualization") var clear_action = clear_test_visualization

var _map: Array = []
var _export_map: Array = []
var _map_size: Vector2i
var _maps_created: bool = false
var _final_spots: Array[Spot] = []
var _export_array: Array = []

#####################################################
#                  MAP OPERATIONS                   #
#####################################################


## initializes _map and _export_map arrays using map dimensions set in _map_size [br]
## initialized arrays are filled with EMPTY_TILE
func _init_maps():
	if _maps_created:
		_delete_maps()
	# create empty column
	var col := PackedInt32Array()
	col.resize(_map_size.y)
	for y in range(_map_size.y):
		col[y] = generation_params.EMPTY_TILE
		
	# fill maps with empty columns
	for r in range(_map_size.x):
		_map.append(col.duplicate())
		_export_map.append(col.duplicate())
	_maps_created = true
	

## clears _map and _export_map arrays
func _delete_maps():
	_clear_2D(_map)
	_clear_2D(_export_map)
	_maps_created = false
	
	
## clear 2D array
func _clear_2D(array: Array):
	for row in array:
		row.clear()
	array.clear()
	
	
## checks if position is located within map array range
func _is_in_map_bounds(position: Vector2i) -> bool:
	if position.x < 0 or position.y < 0 or position.x >= _map_size.x or position.y >= _map_size.y:
		return false
	return true
	
	
## get tile type located at given position
func _get_map_tile(position: Vector2i) -> int:
	if not _is_in_map_bounds(position):
		return generation_params.EMPTY_TILE
	return _map[position.x][position.y]


func _is_road(position: Vector2i) -> bool:
	if _get_map_tile(position) == generation_params.ROAD:
		return true
	return false
	
	
#####################################################
#                     MAP EXPORT                    #
#####################################################


func _export_roads_from_map():
	for x in range(_map_size.x):
		for y in range(_map_size.y):
			_cast_road_to_map(Vector2i(x, y))


func _merge_with_terrain(terrain_map: Array):
	for y in range(_map_size.y):
		for x in range(_map_size.x):
			if terrain_map[x][y]:
				# simply deletes roads where they can't be placed
				# maybe should be made more advanced way later 
				_export_map[x][y] = generation_params.EMPTY_TILE

	
## used on road tile to convert it to export ID
## export ID will be written to _export_map
func _cast_road_to_map(position: Vector2i):
	if _map[position.x][position.y] != generation_params.ROAD:
		return
	var bitmask_key = _get_tile_connections_bitmask(position)
	_export_map[position.x][position.y] = RoadBitmask.get_road_id_from_bitmask(bitmask_key)
	

func _get_tile_connections_bitmask(position: Vector2i):
	var bitmask: int = 0
	var i: int = 0
	for y in range(position.y - 1, position.y + 2):
		for x in range(position.x - 1, position.x + 2):
			if _is_road(Vector2i(x, y)):
				bitmask += 1 << i
			i += 1
	return bitmask
		
		
#####################################################
#      EXPORT MAP CONVERSION TO EXPORT DATA         #
#####################################################


## initialize 2D array for exported data
func _init_export_array():
	if not _export_array.is_empty():
		for row in _export_array:
			row.clear()
		_export_array.clear()
	
	var size: int = RoadBitmask.get_road_id_count()
	_export_array.resize(size)
	for i in range(size):
		_export_array[i] = Array()
	

## convert export map to sorted Vector3 array, grouped by road ID's
func _export_data_array():
	_init_export_array()
	for x in range(_map_size.x):
		for y in range(_map_size.y):
			_export_array[_export_map[x][y]].push_back(Vector3(x, 0, y))
			
			
#####################################################
#                 GENERATOR FUNCTIONS               #
#####################################################


## converts 
func _get_generation_areas() -> Array[Spot]:
	var areas: Array[Spot] = []
	
	generation_params.generation_areas.sort_custom(LimitterArea.sort_by_radius)
	
	# create default area if that was not added as last element of limits array
	if not generation_params.generation_areas.back().area_radius == 1.0:
		printerr("default spot size parameter not found, setting to 3x10")
		var area: LimitterArea = LimitterArea.new()
		area.min_spot_size = Vector2i(3, 3)
		area.max_spot_size = Vector2i(10, 10)
		generation_params.generation_areas.push_back(area)
		
	for i in range(len(generation_params.generation_areas)):
		if (
			generation_params.generation_areas[i].max_spot_size.x 
			< generation_params.generation_areas[i].min_spot_size.x * 2
		):
			printerr("infinite loop detected, max x size for one area was changed")
			generation_params.generation_areas[i].max_spot_size.x = (
				generation_params.generation_areas[i].min_spot_size.x * 2
			)

		if (
			generation_params.generation_areas[i].max_spot_size.y 
			< generation_params.generation_areas[i].min_spot_size.y * 2
		):
			printerr("infinite loop detected, max y size for one area was changed")
			generation_params.generation_areas[i].max_spot_size.y = ( 
				generation_params.generation_areas[i].min_spot_size.y * 2
			)
			
		if generation_params.generation_areas[i].area_radius == 1.0:
			areas.push_back(Spot.create(Vector2i(0, 0), Vector2i(_map_size.x - 1, _map_size.y - 1)))
		else:
			var center: Vector2i = Vector2i(
				int((_map_size.x - 1) / 2.0), int((_map_size.y - 1) / 2.0)
			)
			var offset: Vector2i = Vector2i(
				int(center.x * generation_params.generation_areas[i].area_radius),
				int(center.y * generation_params.generation_areas[i].area_radius)
			)
			areas.push_back(Spot.create_from_center(center, offset))
	
	return areas
	
		
func _generate_spots():
	var spots: Array[Spot] = []
	var areas: Array[Spot] = _get_generation_areas()
	
	# create initial rectangle spot that will be divided into smaller ones
	spots.push_back(Spot.create(Vector2i(0, 0), Vector2i(_map_size.x - 1, _map_size.y - 1)))
	
	# splitting rectangles until they reach proper size
	var steps: int = 0
	while !spots.is_empty():
		var area: int = 0
		var current: int = randi() % len(spots)
		
		while not spots[current].overlaps(areas[area]):
			area += 1
			
		# action decides whether we are splitting x or y direction
		var action = randi() % 2
		
		if (
			spots[current].size_x() > generation_params.generation_areas[area].max_spot_size.x 
			and spots[current].size_x() >= generation_params.generation_areas[area].min_spot_size.x * 2
			and action == 0
		):
			spots.push_back(spots[current].split_x(generation_params.generation_areas[area].min_spot_size))
			steps += 1
		
		if (
			spots[current].size_y() > generation_params.generation_areas[area].max_spot_size.y
			and spots[current].size_y() >= generation_params.generation_areas[area].min_spot_size.y * 2
			and action == 1
		):
			spots.push_back(spots[current].split_y(generation_params.generation_areas[area].min_spot_size))
			steps += 1
			
		# stop splitting spot if it's proper sized and move it to output
		if (
			spots[current].size_x() <= generation_params.generation_areas[area].max_spot_size.x 
			and spots[current].size_y() <= generation_params.generation_areas[area].max_spot_size.y
		):
			_final_spots.push_back(spots.pop_at(current))
			
		# main streets, all spots are moved 1 tile forward to create double roads when casting to map
		if steps == generation_params.highway_generation_time:
			for i in range(len(_final_spots)):
				# avoid rectangles close to map border
				if _final_spots[i].start.x != 0:
					_final_spots[i].start.x += 1
				if _final_spots[i].start.y != 0:
					_final_spots[i].start.y += 1
					
			for i in range(len(spots)):
				# avoid rectangles close to map border
				if spots[i].start.x != 0:
					spots[i].start.x += 1
				if spots[i].start.y != 0:
					spots[i].start.y += 1
			steps += 1
	
	for i in range(len(_final_spots)):
		# avoid rectangles close to map border for better city shape
		if (
			_final_spots[i].start.x != 0 
			and _final_spots[i].start.y != 0 
			and _final_spots[i].end.x != _map_size.x - 1 
			and _final_spots[i].end.y != _map_size.y - 1
		):
			_final_spots[i].cast_on_map(_map, generation_params)
	
	if more_log_messages:
		print("Roads generated, road generation steps: ", steps)


#####################################################
#              MAIN GENERATION FUNCTION             #
#####################################################


## generate roads [br]
## as input provide 2D boolean array where true is terrain which blocks road tile creation [br]
## returns 2D array with positions of road tiles sorted by their ID's (ID's as array indexes)
func generate_roads(terrain_map: Array):
	
	# clear previous generation results
	if not _final_spots.is_empty():
		_final_spots.clear()
	
	_map_size = Vector2i(len(terrain_map), len(terrain_map[0]))
	
	_init_maps()
	_generate_spots()
	
	# avoiding extreme amount of error messages if bitmask creation fails
	# and also avoiding modifying export map to return empty export data on error
	if RoadBitmask.create_bitmask():
		_export_roads_from_map()
		_merge_with_terrain(terrain_map)
	
	_export_data_array()
				
	return _export_array
	

#####################################################
#             DEBUG AND TESTING FUNCTIONS           #
#####################################################


func test() -> void:
	var test_terrain_map: Array = []
	for x in range(test_map_size.x):
		var col := PackedByteArray()
		col.resize(test_map_size.y)
		for y in range(test_map_size.y):
			col[y] = false
		test_terrain_map.append(col)
	if more_log_messages:
		print("start road generation!")
	
	generate_roads(test_terrain_map)
	
	if log_generated_map_to_console:
		_print_map_to_console()
	if log_export_map_to_console:
		_print_export_map_to_console()
	if create_visualization:
		_visualize()
	if more_log_messages:
		print("finished full generation!\n")
	

## printing export map for debug
func _print_export_map_to_console() -> void:
	print("export map:")
		
	for y in range(_map_size.y):
		var output: String = ""
		for x in range(_map_size.x):
			if _export_map[x][y] == 0:
				output += "  "
			elif _export_map[x][y] > 0 and _export_map[x][y] < 10:
				output += " " + str(_export_map[x][y])
			else: 
				output += str(_export_map[x][y])
		print(output)
		
		
## printing generated map for debug
func _print_map_to_console() -> void:
	print("generated map:")
	
	for y in range(_map_size.y):
		var output: String = ""
		for x in range(_map_size.x):
			if _map[x][y] == 0:
				output += "  "
			elif _map[x][y] > 0 and _map[x][y] < 10:
				output += " " + str(_map[x][y])
			else: 
				output += str(_map[x][y])
		print(output)
		

## simple test visualization 
func _visualize() -> void:
	clear_test_visualization()
	
	if more_log_messages:
		print("creating visualization")
		
	for i in range(len(_final_spots)):
		if (
			_final_spots[i].start.x != 0 
			and _final_spots[i].start.y != 0 
			and _final_spots[i].end.x != _map_size.x - 1 
			and _final_spots[i].end.y != _map_size.y - 1
		):
			_final_spots[i].visualize(visualization_container, str(i))
	
	for x in range(_map_size.x):
		for y in range(_map_size.y):
			if _map[x][y] != generation_params.EMPTY_TILE:
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
		n.queue_free()
