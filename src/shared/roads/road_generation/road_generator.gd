@tool
class_name RoadGenerator
extends Node

@export var generation_params: RoadGenerationParams = RoadGenerationParams.new()

@export_tool_button("Generate roads") var generate_action = generate_roads.bind(Dictionary())
# testing flags are splitted into different categories to ensure easy debugging
@export_group("testing")
@export var visualize_limiter_areas: bool
@export var debug_visualization: bool

@export var log_generation_steps: bool
@export_tool_button("Log Generated Map") var log_generated_map_to_console = _print_to_console.bind("type")
@export_tool_button("Log ID's") var log_id_to_console = _print_to_console.bind("id")
@export_tool_button("Log Rotations") var log_rotations_to_console = _print_to_console.bind("rotation")

var _spot_generator = SpotGenerator.new()
var blueprint: Dictionary
var _map_size: int
	
func _process(_delta: float) -> void:
	if visualize_limiter_areas:
		_visualize_limiter_areas()
	if debug_visualization:
		_visualize()
		

## Generate basic road map [br][br]
## Add Limiter Areas to "GenerationAreas" node to customize generation [br][br]
## Clicking "Generate roads" will auto-initialize road generator [br][br]
## Changes tile "type" to "road" from "empty" when places road [br][br]
## Returns false on error
func generate_roads(_blueprint: Dictionary) -> bool:
	if log_generation_steps:
		print("start road generation!")
	
	_map_size = generation_params.map_size
	
	if _blueprint.is_empty():
		# will be replaced by default creation from blueprint class
		_create_default_blueprint()
	else:
		blueprint = _blueprint	
	
	generation_params.generation_areas = _get_generation_areas()
	generation_params.prepare_generation_areas()
	
	_spot_generator.generate_spots(self)
	
	_spot_generator.cast_spots_to_blueprint()
	
	# later will be splitted and used outside of road generator
	var autotiler: RoadAutotile = RoadAutotile.new()
	
	if not autotiler.autotile_roads(blueprint, _map_size):
		return false
		
	if log_generation_steps:
		print("finished full generation!\n")
		
	return true
	

func _create_generation_areas():
	var generation_areas = GenerationAreas.new()
	generation_areas.name = "GenerationAreas"
	self.add_child(generation_areas)
	generation_areas.owner = get_tree().edited_scene_root
	return generation_areas
	

func _get_generation_areas() -> Array[LimiterArea]:
	var generation_areas = find_child("GenerationAreas", false)
	
	if generation_areas == null:
		print("Generation areas not found, adding empty")
		generation_areas = _create_generation_areas()
		
	return generation_areas.get_limiter_areas()


#####################################################
#             DEBUG AND TESTING FUNCTIONS           #
#####################################################


func _create_default_blueprint() -> void:
	for x in _map_size:
		for y in _map_size:
			var coord: Vector2i = Vector2i(x, y)
			blueprint[coord]= {
				"height": 0.0,
				"type": "empty",
				"can_place": "any",
			}


## Printing blueprint map data from given dictionary key for debug
func _print_to_console(key: String) -> void:
	if blueprint.is_empty():
		return
	print("printing '", key, "':")
		
	for y in _map_size:
		var output: String = ""
		for x in _map_size:
			if blueprint[Vector2i(x, y)]["type"] == "road":
				if key == "type":
					output += " R"
				if key == "rotation":
					output += " " + str(blueprint[Vector2i(x, y)][key] / 90)
				if key == "id":
					if blueprint[Vector2i(x, y)][key] >= 0 and blueprint[Vector2i(x, y)][key] < 10:
						output += " " + str(blueprint[Vector2i(x, y)][key])
					else:
						output += str(blueprint[Vector2i(x, y)][key])
			else:
				output += "  "
		print(output)
		

## Simple test visualization
func _visualize() -> void:
	# visualize spots
	for spot in _spot_generator.get_spots():
		spot.visualize()
	
	# visualize roads
	for coord in blueprint.keys():
		if blueprint[coord]["type"] == "road":
			DebugDraw3D.draw_box(
				Vector3(coord.x, 0, coord.y),
					Quaternion.IDENTITY, 
					Vector3(1, 0.01, 1),
					Color(1.0, 1.0, 1.0, 1.0),
					false
				)
				
				
## visualization for better areas setup
func _visualize_limiter_areas():
	for area in _get_generation_areas():
		area.visualize()
