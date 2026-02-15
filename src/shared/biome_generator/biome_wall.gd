extends Node3D

class_name BiomeWall

var adjacent_biomes: Array[Biome] = []
var start_point: Vector2
var end_point: Vector2

func create_wall(start: Vector2, end: Vector2) -> void:
	self.start_point = start
	self.end_point = end

func add_biome(biome: Biome) -> void:
	if adjacent_biomes.find(biome) == -1:
		adjacent_biomes.append(biome)
		biome.add_wall(self)

func remove_biome(biome: Biome) -> void:
	adjacent_biomes.erase(biome)
	try_to_remove()

func try_to_remove() -> void:
	if adjacent_biomes.is_empty():
		self.queue_free()
