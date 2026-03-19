@tool
class_name TerrainManager
extends Node3D

@export_group("Dependencies")
@export var world_generation_params: WorldGenerationParams
@export var world_display_params: WorldDisplayParams
@export var chunk_manager: ChunkManager

@export_group("Debug")
@export var debug_flag: bool

@export_group("Functions")
@export_tool_button("Generate world") var generate_action = generate_world
@export_tool_button("Clear terrain") var clean_action = clean

var blueprint: TerrainBlueprint


func clean() -> void:
	chunk_manager.clear_inactive_chunks()


func _ready() -> void:
	generate_world()


func generate_world() -> void:
	var world_size = world_generation_params.map_size * world_generation_params.chunk_size
	blueprint = TerrainBlueprint.new(world_size)
	clean()

	var generators = get_children().filter(func(c): return c.has_method("execute"))

	for generator in generators:
		if debug_flag == true:
			print("TerrainManager: Starting generation for: " + generator.name)
		generator.execute(self)
		if debug_flag == true:
			print("TerrainManager: Finished generation for: " + generator.name)

	if debug_flag == true:
			print("TerrainManager: Generation completed")
	chunk_manager.begin_generation(self)
