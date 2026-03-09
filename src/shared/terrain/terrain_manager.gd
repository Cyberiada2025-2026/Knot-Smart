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
@export var chunk_generator: ChunkGenerator

@export_group("Functions")
@export_tool_button("Generate world") var generate_action = generate_world
@export_tool_button("Clear terrain") var clean_action = _clean

var blueprint: TerrainBlueprint
var can_generate_chunks = false

func setup_components() -> void:
	if terrain_generator: 
		terrain_generator.world_generation_params = world_generation_params
	if chunk_generator: 
		chunk_generator.world_generation_params = world_generation_params
		chunk_generator.world_display_params = world_display_params
	print("TerrainManager: Components initialized with shared WorldGenParams.")
	
func _clean() -> void:
	chunk_generator.clear_chunks()

func _ready() -> void:
	generate_world()

func generate_world() -> void:
	
	setup_components()
	var world_size = world_generation_params.map_size*world_generation_params.chunk_size
	blueprint = TerrainBlueprint.new(world_size)
	
	if terrain_generator and terrain_generator.has_method("generate_terrain"):
		chunk_generator.clear_chunks()
		terrain_generator.generate_terrain(blueprint)
		
	if road_generator and road_generator.has_method("generate_roads"):
		road_generator.generate_roads(blueprint)
	else:
		push_warning("TerrainManager: Road Generator skipped or method missing.")
		
	if building_generator and building_generator.has_method("generate_buildings"):
		building_generator.generate_buildings(blueprint)
	else:
		push_warning("TerrainManager: Building Generator skipped or method missing.")
	
	# temp solution
	if chunk_generator and chunk_generator.has_method("generate_chunks"):
		if player:
			chunk_generator.generate_chunks(blueprint,player.player_physics.position)
		else:
			chunk_generator.generate_chunks(blueprint)
	else:
		push_warning("TerrainManager: Missing valid Chunk Generator!")
	
	can_generate_chunks = true
	
func _process(_delta: float) -> void:
	if can_generate_chunks == true and not Engine.is_editor_hint():
		chunk_generator.generate_chunks(blueprint, player.player_physics.position)
	
