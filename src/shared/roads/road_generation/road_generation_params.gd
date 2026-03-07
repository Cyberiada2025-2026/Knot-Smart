@tool
class_name RoadGenerationParams
extends Resource

var DEFAULT_LIMIT_AREA = LimiterArea.new()

## Min and max spot size dimensions are decreased by 1 when creating road map. [br][br]
var generation_areas: Array[LimiterArea]
		
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
	# spots are sorted by their area, ascending
	generation_areas.sort_custom(func(a,b): return a.spot_limit_area.area()< b.spot_limit_area.area())


func get_area(overlapping_spot: Spot) -> LimiterArea:
	var area_idx = generation_areas.find_custom(_find_overlap_with_area.bind(overlapping_spot))
	return DEFAULT_LIMIT_AREA if area_idx == -1 else generation_areas[area_idx]


func _find_overlap_with_area(area: LimiterArea, spot: Spot):
	return area.spot_limit_area.overlaps(spot)
