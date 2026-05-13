@tool
class_name PassagesGenerator
extends Node3D


@export var generator_main: PlantsWallsGenerator

var params: PlantWallGeneratorParams
var data: PlantWallsSaver


func reset() -> void:
	params = generator_main.params
	data = generator_main.data
	data.passage_lines.clear()

func generate() -> void:
	params = generator_main.params
	data = generator_main.data
	_generate_passage_lines()
	_generate_passages()

func _generate_passage_lines() -> void:
	var biomes_copy = data.biomes.duplicate(false)
	for biome in data.biomes:
		biomes_copy.erase(biome)
		for biome2 in biomes_copy:
			if biome2 in biome.adjustent_biomes:
				var passage_line = PassageLine.new()
				data.passage_lines.append(passage_line)
				data.walls_combiner.add_child(passage_line)
				passage_line.owner = data
				for line in biome.lines:
					if biome2.lines.find(line) >= 0:
						passage_line.lines.append(line)

func _generate_passages() -> void:
	for passage_line in data.passage_lines:
		var lines_copy: Array[BiomeLine] = passage_line.lines.duplicate(false)
		for i in range(params.number_of_passages_per_biomes_border):
			if lines_copy.size() > 0:
				var line = data.rng.pick_random(lines_copy)
				lines_copy.erase(line)
				_create_passage_on_line(line, passage_line)

func _create_passage_on_line(
	line: BiomeLine,
	passage_line: PassageLine
) -> void:
	var passage := params.passage_prefab.instantiate()
	passage_line.add_child(passage)
	passage.owner = data
	var middle := line.get_middle()
	passage.position = Vector3(middle.x, passage.radius/2, middle.y)
