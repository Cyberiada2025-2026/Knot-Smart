@tool
class_name BiomeWallsGenerator
extends Node3D

@export var generator_main: PlantsWallsGenerator

func reset() -> void:
	if generator_main.walls_combiner != null:
		generator_main.walls_combiner.reparent(self)
		generator_main.walls_combiner.owner = self
		generator_main.walls_combiner.queue_free()
	generator_main.walls_combiner = WallsCombiner.new()
	generator_main.saved_nodes_node.add_child(generator_main.walls_combiner)
	generator_main.walls_combiner.owner = generator_main

func generate() -> void:
	for line_key in generator_main.triangle_generator.lines:
		var line: BiomeLine = generator_main.triangle_generator.lines[line_key]
		if not line.biomes.is_empty():
			var wall: BiomeWall = BiomeWall.new()
			generator_main.walls_combiner.add_child(wall)
			wall.owner = generator_main
			wall.create_wall(line.start_point, line.end_point)
			for biome in line.biomes:
				wall.add_biome(biome)
