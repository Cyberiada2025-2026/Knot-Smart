@tool
class_name BiomeTriangle
extends Node

var lines: Array[BiomeLine]
var biome: Biome


func get_area() -> float:
	return (abs(lines[0].get_vector().cross(lines[1].get_vector()))/2)
