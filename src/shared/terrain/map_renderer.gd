@tool
class_name MapRenderer
extends Node3D

@export_group("Dependencies")
@export var world_generation_params: WorldGenerationParams
@export var world_display_params: WorldDisplayParams

@export_group("Debug")
@export var debug_flag: bool
@export_tool_button("Generate Map") var generate_map = begin_generation
@export_tool_button("Clear Map") var clear_map = clear_generation

var blueprint: MapTileData
var chunk_manager: ChunkManager
var map_instancer: MapInstancer


func begin_generation():
	clear_generation()
	var world_size = world_generation_params.map_size * world_generation_params.chunk_size
	blueprint = MapTileData.new(world_size)

	var pipelines = get_children().filter(func(c): return c.has_method("run_pipeline"))

	for pipeline in pipelines:
		if debug_flag == true:
			print(self.name + ": Starting generation pipeline: " + pipeline.name)
		pipeline.run_pipeline(self)
		if debug_flag == true:
			print(self.name + ": Finished generation for: " + pipeline.name)

	map_instancer = MapInstancer.new(self)

	map_instancer.create_map_instance()

	if Engine.is_editor_hint() == true:
		chunk_manager = ChunkManager.new()
		chunk_manager.setup(self)
		chunk_manager.name = "Chunks"


func clear_generation():
	for child in get_children():
		if child.name == "Chunks" or child is ChunkManager:
			if debug_flag:
				print("%s: Removing existing ChunkManager: %s" % [self.name, child.name])

			child.queue_free()

	blueprint = null
	map_instancer = null


func _ready():
	clear_generation()
	if Engine.is_editor_hint() == false:
		chunk_manager = ChunkManager.new()
		chunk_manager.setup(self)
		chunk_manager.name = "Chunks"
