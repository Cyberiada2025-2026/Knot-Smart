extends Resource
class_name RoadGenerationParams

# min and max spot size dimensions are decreased by 1 when exporting road map
# max size should be at least 2x bigger than min size(otherwise will be resized automatically)
# default spot dimensions when spot in not located in any specific area should be added as object with radius 1.0
@export var generation_areas: Array[LimitterArea]

## determines amount of tile splits after which highways will generate [br]
## for bigger maps higher value recommended
@export var highway_generation_split_count = 20

# 
enum {
	EMPTY_TILE = 0,
	TERRAIN,
	ROAD,
	HIGHWAY
}
