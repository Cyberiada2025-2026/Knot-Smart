@tool
class_name BiomeWallsGenerator
extends Node3D

@export var generator_main: PlantsWallsGenerator

func create_walls() -> void:
	generator_main.walls_combiner = WallsCombiner.new()
	self.add_child(generator_main.walls_combiner)
	generator_main.walls_combiner.owner = self
	for line_key in generator_main.triangle_generator.lines:
		var line: BiomeLine = generator_main.triangle_generator.lines[line_key]
		if not line.biomes.is_empty():
			var wall: BiomeWall = BiomeWall.new()
			generator_main.walls_combiner.add_child(wall)
			wall.create_wall(line.start_point, line.end_point)
			for biome in line.biomes:
				wall.add_biome(biome)
