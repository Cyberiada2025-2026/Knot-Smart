extends Node
class_name Biome

var biome_name: String = ""
var area: float = 0
var color: Color = Color.BLUE
var triangles: Array[BiomeTriangle] = []
var lines: Array[BiomeLine] = []
var walls: Array[BiomeWall] = []

func open_biome() -> void:
	for wall: BiomeWall in walls:
		wall.remove_biome(self)

func add_wall(wall: BiomeWall) -> void:
	if walls.find(wall) == -1:
		walls.append(wall)
