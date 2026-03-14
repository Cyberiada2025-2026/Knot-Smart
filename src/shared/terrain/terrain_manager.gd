@tool
class_name TerrainManager
extends Node3D

@export var player: Player

@export_group("Params")
@export var world_generation_params: WorldGenerationParams
@export var world_display_params: WorldDisplayParams

@export_group("Functions")
@export_tool_button("Generate world") var generate_action = generate_world
@export_tool_button("Clear terrain") var clean_action = clear_t

signal terrain_generation_finished(blueprint: TerrainBlueprint)
signal clear_terrain

var blueprint: TerrainBlueprint
	
func clear_t() -> void:
	clear_terrain.emit()
	
func _ready() -> void:
	generate_world()

func generate_world() -> void:
	
	var world_size = world_generation_params.map_size*world_generation_params.chunk_size
	blueprint = TerrainBlueprint.new(world_size)
	clear_t()
	
	var generators = get_children().filter(func(c): return c.has_method("execute"))
	
	for generator in generators:
		generator.execute(self)
	
	terrain_generation_finished.emit(blueprint)
	
