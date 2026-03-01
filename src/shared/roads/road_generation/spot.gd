@tool
extends Resource

#single spot for building placement and roads, uses parts of cell.gd code from room generator
class_name Spot

# start coordinates should be always smaller than end coordinates
@export var start: Vector2i = Vector2i.ZERO
@export var end: Vector2i = Vector2i.ONE

func _init(_start: Vector2i = Vector2i.ZERO, _end: Vector2i = Vector2i.ONE) -> void:
	# ensure that start coordinates are smaller than end
	start = Vector2i(mini(_start.x, _end.x), mini(_start.y, _end.y))
	end = Vector2i(maxi(_start.x, _end.x), maxi(_start.y, _end.y))
	
	
func size() -> Vector2i:
	return end - start
	
	
func area() -> int:
	return size().x * size().y
	

func overlaps(other: Spot) -> bool:
	return (
		self.start.x < other.end.x 
		and other.start.x < self.end.x
		and self.start.y < other.end.y
		and other.start.y < self.end.y
	)
	
	
func _get_spot_border_coordinates() -> Array[Vector2i]:
	var coordinates: Array[Vector2i]
	for x in range(start.x, end.x + 1):
		coordinates.push_back(Vector2i(x, start.y))
		coordinates.push_back(Vector2i(x, end.y))
		
	for y in range(start.y, end.y + 1):
		coordinates.push_back(Vector2i(start.x, y))
		coordinates.push_back(Vector2i(end.x, y))
	return coordinates


func cast_on_blueprint(blueprint: Dictionary):
	for pos in _get_spot_border_coordinates():
		blueprint[pos]["type"] = "road"
