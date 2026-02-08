extends Node
class_name Biome

#@export var name: String = ""
var area: float = 0
var triangles: Array[BiomeTriangle] = []
var lines: Array[BiomeLine] = []
var color: Color = Color.BLUE
