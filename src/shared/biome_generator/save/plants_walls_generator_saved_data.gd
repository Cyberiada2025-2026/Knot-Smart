@tool
class_name PlantWallsSaver
extends Node3D

# LINE TYPES
const VERTICAL_LINE = 0
const HORIZONTAL_LINE = 1
const DIAGONAL_LINE = 2

@export var custom_seed: int

# Nodes
@export var walls_combiner: WallsCombiner

# PATH
@export var path_location: String = "user://"  #"res://"
@export var path_folder: String = "biomegenerator/"
@export var path_file_name: String = "generated_biome"
@export var path_file_extension: String = ".tscn"

# DATA FROM GENERATORS
@export var points: Dictionary[Vector2, Vector2] = {}
## Dictionary with x,y beeing position and z representing type of line
@export var lines: Dictionary[Vector3, BiomeLine]
@export var triangles: Array[BiomeTriangle]
@export var biomes: Array[Biome]
@export var passage_lines: Array[PassageLine] = []

var rng: RandomNumberGeneratorUpgraded


func save() -> void:
	var path: String = get_file_path()
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error != OK:
			print("BIOME GENERATOR SAVING ERROR: ", error)
	else:
		var error = DirAccess.make_dir_recursive_absolute(path_location + path_folder)
		if error != OK:
			print("BIOME GENERATOR SAVING DIRECTORY ERROR: ", error)
	var scene: PackedScene = PackedScene.new()
	scene.pack(self)
	ResourceSaver.save(scene, path)


func get_file_path() -> String:
	return path_location + path_folder + path_file_name + path_file_extension
