@tool
class_name TerrainManager
extends Node3D

@export var player: Player
@export_tool_button("Generate world") var generate_action = generate_world
@export_tool_button("Setup Components") var setup_action = setup_components

@export_group("Params")
@export var world_generation_params: WorldGenerationParams
@export var world_display_params: WorldDisplayParams

@export_group("Generators")
@export var terrain_generator: TerrainGenerator
@export var road_generator: Node
@export var building_generator: Node
@export var chunk_generator: ChunkGenerator


var blueprint: Dictionary = {} # Vector2i: TileData
var can_generate_chunks = false

func setup_components() -> void:
	if terrain_generator: 
		terrain_generator.world_generation_params = world_generation_params
	if chunk_generator: 
		chunk_generator.world_generation_params = world_generation_params
		chunk_generator.world_display_params = world_display_params
	print("TerrainManager: Components initialized with shared WorldGenParams.")

func create_default_blueprint() -> void:
	blueprint.clear()
	for x in range(world_generation_params.map_size):
		for z in range(world_generation_params.map_size):
			var coord = Vector2i(x, z)
			blueprint[coord] = {
				"height": 0.0,      # Flat ground at sea level
				"type": "empty",
				"can_place": "any",
			}
			
	print("TerrainManager: Default flat blueprint created")
					
	
func _ready() -> void:
	setup_components()

func generate_world() -> void:
	
	blueprint.clear()
	
	if terrain_generator and terrain_generator.has_method("generate_terrain"):
		var terrain_check = true
		terrain_check = terrain_generator.generate_terrain(blueprint)
		
		if terrain_check == false or blueprint.is_empty():
			push_error("TerrainManager: Generation Failed!")
			create_default_blueprint()
			
	else:
		push_error("TerrainManager: Missing valid Terrain Generator!")
		create_default_blueprint()
		
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
		chunk_generator.generate_chunks(blueprint,player.position)
	else:
		push_warning("TerrainManager: Missing valid Chunk Generator!")
	
	
	can_generate_chunks = true
	
func _process(delta: float) -> void:
	if can_generate_chunks == true:
		chunk_generator.generate_chunks(blueprint, player.position)
	
