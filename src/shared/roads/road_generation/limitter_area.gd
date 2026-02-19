extends Resource
class_name LimitterArea

# spot size limits, generated spots in this area will have size between limits
# min and max spot size dimensions are decreased by 1 when creating road map
# max size should be at least 2x bigger than min size(otherwise will be resized automatically)
@export var min_spot_size: Vector2i = Vector2i(3, 3)
@export var max_spot_size: Vector2i = Vector2i(10, 10)

# radius from map center where spot limits will be applied 
# value between 0 and 1, representing percent of radius
@export_range(0.0, 1.0) var area_radius: float = 1.0


static func sort_by_radius(a: LimitterArea, b: LimitterArea):
	if a.area_radius < b.area_radius:
		return true
	return false
