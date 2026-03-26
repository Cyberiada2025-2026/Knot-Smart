@tool
class_name GridGenerationPipeline
extends Node

@export_group("Debug")
@export var debug_flag: bool

var world_generation_params
var blueprint: MapTileData

func run_pipeline(manager: MapRenderer) -> void:
	world_generation_params = manager.world_generation_params
	blueprint = manager.blueprint
	
	var generators = get_children().filter(func(c): return c.has_method("run_generation"))

	for generator in generators:
		if debug_flag == true:
			print(self.name + ": Starting generation for: " + generator.name)
		generator.run_generation(self)
		if debug_flag == true:
			print(self.name + ": Finished generation for: " + generator.name)

	if debug_flag == true:
		print(self.name + ": Generation completed")
		
	
