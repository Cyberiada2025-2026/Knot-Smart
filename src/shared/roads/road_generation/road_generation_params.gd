@tool
class_name RoadGenerationParams
extends Resource

# TODO make const
var DEFAULT_LIMIT_AREA = LimiterArea.new()

## Min and max spot size dimensions are decreased by 1 when creating road map. [br][br]
@export var generation_areas: Array[LimiterArea] = [LimiterArea.new()]:
	set(value):
		generation_areas = value
		if generation_areas.is_empty() or generation_areas.back() == null:
			generation_areas.pop_back()
			generation_areas.push_back(LimiterArea.new())
		

## Determines amount of tile splits after which highways will generate. [br]
## For bigger maps higher value recommended
@export var highway_generation_split_count = 20

## TODO later use value from world generation params 
@export_range(4, 2048, 4) var map_size: int = 64

## Number of all generation steps(including unsuccessful) [br]
## after which generator will stop splitting spots. [br][br]
## Ensures proper exit when terrain don't allow proper spot splitting. [br][br]
## For bigger map larger numbers recommended
@export var generation_steps_limit: int = 10000

enum {
	EMPTY_TILE = 0,
	TERRAIN,
	ROAD,
	HIGHWAY
}

## Format areas to make them usable for generator
func prepare_generation_areas():
	generation_areas = generation_areas.filter(func(area): return area != null)

	# spots are sorted by their area, ascending
	generation_areas.sort_custom(func(a,b): return a.spot_limit_area.area()< b.spot_limit_area.area())
		
	# show sorted values in editor
	notify_property_list_changed()
