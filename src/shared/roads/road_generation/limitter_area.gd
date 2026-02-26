@tool
extends Resource
class_name LimitterArea

## spot size limits, generated spots in this area will have size between limits [br]
## max size should be at least 2x bigger than min size [br]
## (values will be corrected automatically)
@export var min_spot_size: Vector2i = Vector2i(3, 3):
	set(value):
		min_spot_size = value
		for axis in Utils.Axis2.values():
			if min_spot_size[axis] * 2 > max_spot_size[axis]:
				max_spot_size[axis] = min_spot_size[axis] * 2
				print("corrected max size")

# somehow sometimes corrects last array's min_spot_size.y for no reason, still trying to figure out why
@export var max_spot_size: Vector2i = Vector2i(10, 10):
	set(value):
		max_spot_size = value
		for axis in Utils.Axis2.values():
			if min_spot_size[axis] * 2 > max_spot_size[axis]:
				min_spot_size[axis] = int(max_spot_size[axis] / 2.0)
				print("corrected min size")

## area where spot limits will be applied 
@export var spot_limit_area: Spot = Spot.new()
	
