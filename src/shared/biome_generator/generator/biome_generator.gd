@tool
class_name BiomeGenerator
extends Node3D

@export var generator_main: PlantsWallsGenerator
@export var biomes_parent: Node
@export_category("GeneratorVariables")
## Minimal area of biomes in m^2
@export var biomes_desired_minimum_area: Dictionary[String, int] = {
	"biome1": 10000,
	"biome2": 10000,
	"biome3": 10000
}
@export_group("triangles selection")
## chance to shuffle possible triangles, during every selection of next biome triangle
@export var chance_to_shuffle: float = 0.01

var biomes: Array[Biome]

var _free_triangles: Array[BiomeTriangle]
var _size_proportion: Dictionary[Biome, float]

func reset() -> void:
	pass

func generate_biomes() -> void:
	_free_triangles = generator_main.triangle_generator.triangles.duplicate(false)
	_init_biomes()
	while _free_triangles.size() > 0:
		var minimal: float = _size_proportion.values().min()
		var biome: Biome = _size_proportion.find_key(minimal)
		_get_biome_new_triangle(biome)
		if not biome.is_able_to_expand:
			_size_proportion[biome] = INF
		else:
			_size_proportion[biome] = biome.area / biomes_desired_minimum_area[biome.biome_name]
	for biome in biomes:
		for line in biome.lines:
			line.biomes.append(biome)
		for triangle in biome.triangles:
			triangle.biome = biome



func _init_biomes() -> void:
	for biome_name in biomes_desired_minimum_area:
		var biome: Biome = Biome.new()
		_init_biome(biome, biome_name)
		_get_biome_random_free_triangle(biome)
		_size_proportion[biome] = biome.area / biomes_desired_minimum_area[biome_name]

func _init_biome(biome: Biome, biome_name: String) -> void:
	biomes_parent.add_child(biome)
	biomes.append(biome)
	biome.name = biome_name
	biome.biome_name = biome_name


func _get_biome_random_free_triangle(biome: Biome) -> void:
	var triangle: BiomeTriangle = generator_main.rng.pick_random(_free_triangles)
	_add_triangle_to_biome(biome, triangle)


func _add_triangle_to_biome(biome: Biome, triangle: BiomeTriangle) -> void:
	_free_triangles.erase(triangle)
	biome.triangles.append(triangle)
	for line in triangle.lines:
		_add_line_to_biome(biome, line)
	biome.area += triangle.get_area()


func _add_line_to_biome(biome: Biome, line: BiomeLine) -> void:
	if line.adjacent_triangles.size() == 1:
		biome.lines.append(line)
		return
	for triangle in line.adjacent_triangles:
		if biome.triangles.find(triangle) == -1:
			biome.lines.append(line)
			return
		biome.lines.erase(line)


func _get_biome_new_triangle(biome: Biome) -> void:
	if generator_main.rng.randf() <= chance_to_shuffle:
		generator_main.rng.shuffle(biome.lines)
	var line_count: int = biome.lines.size()
	for i in range(line_count):
		var line: BiomeLine = biome.lines.pop_front()
		for triangle in line.adjacent_triangles:
			if _free_triangles.find(triangle) >= 0:
				_add_triangle_to_biome(biome, triangle)
				return
		biome.lines.push_back(line)
	if biome.area >= biomes_desired_minimum_area[biome.biome_name]:
		biome.is_able_to_expand = false
	else:
		_get_biome_random_free_triangle(biome)
