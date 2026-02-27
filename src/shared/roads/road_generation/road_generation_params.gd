@tool
extends Resource
class_name RoadGenerationParams

## min and max spot size dimensions are decreased by 1 when creating road map [br]
## default spot dimension limits: 3x3 to 10x10
@export var generation_areas: Array[LimitterArea] = [LimitterArea.new()]:
	set(value):
		generation_areas = value
		if generation_areas.is_empty() or generation_areas.back() == null:
			generation_areas.pop_back()
			generation_areas.push_back(LimitterArea.new())
		

## determines amount of tile splits after which highways will generate [br]
## for bigger maps higher value recommended
@export var highway_generation_split_count = 20

## TODO later use value from world generation params 
@export_range(4, 2048, 4) var map_size: int = 64

enum {
	EMPTY_TILE = 0,
	TERRAIN,
	ROAD,
	HIGHWAY
}


func check_generation_areas():
	# spots are sorted by their area, ascendant
	generation_areas.sort_custom(func(a,b): return a.spot_limit_area.area()< b.spot_limit_area.area())
		
	# add default case for every other situation
	if generation_areas.back().spot_limit_area.area() < map_size * map_size:
		var area: LimitterArea = LimitterArea.new()
		area.spot_limit_area.end = Vector2i(map_size, map_size)
		generation_areas.push_back(area)
		print("Added default area to generation params")
		
	# show sorted values in editor
	notify_property_list_changed()
