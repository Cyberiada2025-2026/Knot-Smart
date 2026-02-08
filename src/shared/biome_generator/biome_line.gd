extends Node
class_name BiomeLine

var start_point: Vector2
var end_point: Vector2
var adjacent_triangles: Array[BiomeTriangle]
var biomes: Array[Biome]

func get_length() -> float:
	return sqrt(pow((end_point.x - start_point.x), 2) + pow((end_point.y - start_point.y), 2))

func get_rotation() -> float:
	return -atan((end_point.y - start_point.y)/(end_point.x - start_point.x))
