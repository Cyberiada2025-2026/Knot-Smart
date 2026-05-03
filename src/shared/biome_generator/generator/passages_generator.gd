@tool
class_name PassagesGenerator
extends Node3D


@export var generator_main: PlantsWallsGenerator
@export var passage_prefab: PackedScene = preload("res://shared/biome_generator/wall/biome_passage.tscn")
@export_category("VARIABLES")
@export var number_of_passages_per_biomes_border: int = 3

var passage_lines: Array[PassageLine] = []

func reset() -> void:
	passage_lines.clear()

func generate() -> void:
	_generate_passage_lines()
	_generate_passages()

func _generate_passage_lines() -> void:
	var biomes_copy = generator_main.biome_generator.biomes.duplicate(false)
	for biome in generator_main.biome_generator.biomes:
		biomes_copy.erase(biome)
		for biome2 in biomes_copy:
			if biome2 in biome.adjustent_biomes:
				var passage_line = PassageLine.new()
				passage_lines.append(passage_line)
				generator_main.walls_combiner.add_child(passage_line)
				passage_line.owner = generator_main
				for line in biome.lines:
					if biome2.lines.find(line) >= 0:
						passage_line.lines.append(line)

func _generate_passages() -> void:
	for passage_line in passage_lines:
		var lines_copy: Array[BiomeLine] = passage_line.lines.duplicate(false)
		for i in range(number_of_passages_per_biomes_border):
			var line = lines_copy.pick_random()
			lines_copy.erase(line)
			_create_passage_on_line(line, passage_line)

func _create_passage_on_line(
	line: BiomeLine,
	passage_line: PassageLine
) -> void:
	var passage := passage_prefab.instantiate()
	passage_line.add_child(passage)
	passage.owner = generator_main
	var middle := line.get_middle()
	passage.position = Vector3(middle.x, passage.radius/2, middle.y)
