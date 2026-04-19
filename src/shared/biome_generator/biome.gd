@tool
class_name Biome
extends Node

var biome_name: String = ""
var area: float = 0
var adjustent_biomes: Array[Biome] = []
var triangles: Array[BiomeTriangle] = []
var lines: Array[BiomeLine] = []
var walls: Array[BiomeWall] = []
var passage: Array[Node3D] = []
var is_able_to_expand = true

func open_biome() -> void:
	for wall: BiomeWall in walls:
		wall.remove_biome(self)


func add_wall(wall: BiomeWall) -> void:
	if walls.find(wall) == -1:
		walls.append(wall)
