class_name PassageLine
extends CSGCombiner3D

var biomes: Array[Biome] = []
var lines: Array[BiomeLine] = []

func _ready() -> void:
	operation = CSGShape3D.OPERATION_SUBTRACTION
