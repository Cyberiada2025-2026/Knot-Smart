@tool
class_name BiomeWallsGenerator
extends Node3D

@export var generator_main: PlantsWallsGenerator

var params: PlantWallGeneratorParams
var data: PlantWallsSaver


func reset() -> void:
	params = generator_main.params
	data = generator_main.data
	if data.walls_combiner != null:
		data.walls_combiner.owner = self
		data.walls_combiner.reparent(self)
		data.walls_combiner.queue_free()
	data.walls_combiner = WallsCombiner.new()
	data.add_child(data.walls_combiner)
	data.walls_combiner.owner = data


func generate() -> void:
	params = generator_main.params
	data = generator_main.data
	for line_key in data.lines:
		var line: BiomeLine = data.lines[line_key]
		if not line.biomes.is_empty():
			var wall: BiomeWall = BiomeWall.new()
			data.walls_combiner.add_child(wall)
			wall.owner = data
			wall.create_wall(line.start_point, line.end_point)
			for biome in line.biomes:
				wall.add_biome(biome)
