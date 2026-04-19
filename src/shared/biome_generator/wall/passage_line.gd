extends CSGCombiner3D
class_name PassageLine

var biomes: Array[Biome] = []
var lines: Array[BiomeLine] = []

func _ready() -> void:
	operation = CSGShape3D.OPERATION_SUBTRACTION
