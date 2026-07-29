@tool
class_name BiomeGenerator
extends Node3D

@export var generator_main: PlantsWallsGenerator

var params: PlantWallGeneratorParams
var data: PlantWallsSaver

var _free_triangles: Array[BiomeTriangle]
var _size_proportion: Dictionary[Biome, float]


func reset() -> void:
	params = generator_main.params
	data = generator_main.data
	data.biomes.clear()
	_free_triangles.clear()
	_size_proportion.clear()


func generate() -> void:
	params = generator_main.params
	data = generator_main.data
	_free_triangles = data.triangles.duplicate(false)
	_init_biomes()
	while _free_triangles.size() > 0:
		var minimal: float = _size_proportion.values().min()
		var biome: Biome = _size_proportion.find_key(minimal)
		_get_biome_new_triangle(biome)
		if not biome.is_able_to_expand:
			_size_proportion[biome] = INF
		else:
			_size_proportion[biome] = biome.area / params.biomes_desired_minimum_area[biome.name]
	for biome in data.biomes:
		for line in biome.lines:
			for l_biome in line.biomes:
				if not l_biome in biome.adjustent_biomes:
					biome.adjustent_biomes.append(l_biome)
				if not biome in l_biome.adjustent_biomes:
					l_biome.adjustent_biomes.append(biome)
			line.biomes.append(biome)
		for triangle in biome.triangles:
			triangle.biome = biome


func _init_biomes() -> void:
	for biome_name in params.biomes_desired_minimum_area:
		var biome: Biome = Biome.new()
		_init_biome(biome, biome_name)
		_get_biome_random_free_triangle(biome)
		_size_proportion[biome] = biome.area / params.biomes_desired_minimum_area[biome_name]


func _init_biome(biome: Biome, biome_name: String) -> void:
	data.biomes.append(biome)
	biome.name = biome_name


func _get_biome_random_free_triangle(biome: Biome) -> void:
	var triangle: BiomeTriangle = data.rng.pick_random(_free_triangles)
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
	if data.rng.randf() <= params.chance_to_shuffle:
		data.rng.shuffle(biome.lines)
	var line_count: int = biome.lines.size()
	for i in range(line_count):
		var line: BiomeLine = biome.lines.pop_front()
		for triangle in line.adjacent_triangles:
			if _free_triangles.find(triangle) >= 0:
				_add_triangle_to_biome(biome, triangle)
				return
		biome.lines.push_back(line)
	if biome.area >= params.biomes_desired_minimum_area[biome.name]:
		biome.is_able_to_expand = false
	_get_biome_random_free_triangle(biome)
