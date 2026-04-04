@tool
class_name Biome
extends Node

var biome_name: String = ""
var area: float = 0
var triangles: Array[BiomeTriangle] = []
var lines: Array[BiomeLine] = []
var walls: Array[BiomeWall] = []


func open_biome() -> void:
	for wall: BiomeWall in walls:
		wall.remove_biome(self)


func add_wall(wall: BiomeWall) -> void:
	if walls.find(wall) == -1:
		walls.append(wall)
