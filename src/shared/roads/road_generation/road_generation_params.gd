@tool
extends Resource
class_name RoadGenerationParams

## min and max spot size dimensions are decreased by 1 when creating road map [br]
## default spot dimensions: [br]

@export var generation_areas: Array[LimitterArea]:
	set(value):
		generation_areas = value
		check_generation_areas()
		

## determines amount of tile splits after which highways will generate [br]
## for bigger maps higher value recommended
@export var highway_generation_split_count = 20

## TODO later use value from world generation params 
@export var map_size: int = 51


enum {
	EMPTY_TILE = 0,
	TERRAIN,
	ROAD,
	HIGHWAY
}


func check_generation_areas():
	# sorted automatically but not updating view for more comfortable params setting
	# spots are sorted by their area, ascendant
	generation_areas.sort_custom(func(a,b): return a.spot_limit_area.area()< b.spot_limit_area.area())
		
	# add default case for every other situation
	# not fully idiot-proof - ensure full from spot.gd code
	if generation_areas.back().spot_limit_area.area() < map_size * map_size:
		var area: LimitterArea = LimitterArea.new()
		area.spot_limit_area.end = Vector2i(map_size, map_size)
		generation_areas.push_back(area)
		notify_property_list_changed()
		print("Added default area to generation params")
