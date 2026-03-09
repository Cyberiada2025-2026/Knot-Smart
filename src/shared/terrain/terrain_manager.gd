@tool
class_name TerrainManager
extends Node3D

@export var player: Player

@export_group("Params")
@export var world_generation_params: WorldGenerationParams
@export var world_display_params: WorldDisplayParams

@export_group("Generators")
@export var terrain_generator: TerrainGenerator
@export var road_generator: Node
@export var building_generator: Node
@export var chunk_manager: ChunkManager

@export_group("Functions")
@export_tool_button("Generate world") var generate_action = generate_world
@export_tool_button("Clear terrain") var clean_action = _clean

var blueprint: TerrainBlueprint
var can_generate_chunks = false

func setup_components() -> void:
	
	if not terrain_generator:
		push_warning("TerrainManager: TerrainGenerator missing. Created new.")
		terrain_generator = TerrainGenerator.new()
		add_child(terrain_generator)
	
	if not chunk_manager:
		push_warning("TerrainManager: ChunkManager missing. Created new.")
		chunk_manager = ChunkManager.new()
		add_child(chunk_manager)

	if not world_generation_params:
		world_generation_params = WorldGenerationParams.new()
		push_warning("TerrainManager: WorldGenParams missing. Created new.")

	if not world_display_params:
		world_display_params = WorldDisplayParams.new()
		push_warning("TerrainManager: WorldDisplayParams missing. Created new.")

	terrain_generator.world_generation_params = world_generation_params
	chunk_manager.world_generation_params = world_generation_params
	chunk_manager.world_display_params = world_display_params
	print("TerrainManager: Setup complete.")
	
func _clean() -> void:
	chunk_manager.clear_inactive_chunks()

func _ready() -> void:
	generate_world()

func generate_world() -> void:
	
	setup_components()
	
	var world_size = world_generation_params.map_size*world_generation_params.chunk_size
	
	blueprint = TerrainBlueprint.new(world_size)
	
	chunk_manager.clear_inactive_chunks()
	terrain_generator.generate_terrain(blueprint)
	
	if player:
		chunk_manager.generate_chunks(blueprint,player.player_physics.position)
	else:
		chunk_manager.generate_chunks(blueprint)
	
	can_generate_chunks = true
	
func _process(_delta: float) -> void:
	if can_generate_chunks == true and not Engine.is_editor_hint():
		chunk_manager.generate_chunks(blueprint, player.player_physics.position)
	
