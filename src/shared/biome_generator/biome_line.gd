@tool
class_name BiomeLine
extends Node

var start_point: Vector2
var end_point: Vector2
var adjacent_triangles: Array[BiomeTriangle]
var biomes: Array[Biome]


func get_length() -> float:
	return start_point.distance_to(end_point)


func get_rotation() -> float:
	return -atan((end_point.y - start_point.y) / (end_point.x - start_point.x))


func get_vector() -> Vector2:
	return end_point - start_point

func get_middle() -> Vector2:
	return (start_point + end_point)/2
