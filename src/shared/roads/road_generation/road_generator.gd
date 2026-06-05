@tool
class_name RoadGenerator
extends Node

@export var generation_params: RoadGenerationParams = RoadGenerationParams.new()

@export_tool_button("Generate roads") var generate_action = run_generation.bind(blueprint)

@export_group("Testing")
@export var limit_areas_visualization: bool
@export var map_visualization: bool

@export var log_generation_steps: bool
@export_tool_button("Log Generated Map") var log_generated_map_to_console = (
	_print_to_console.bind("type")
)
@export_tool_button("Log ID's") var log_id_to_console = _print_to_console.bind("id")
@export_tool_button("Log Rotations") var log_rotations_to_console = (
	_print_to_console.bind("rotation")
)

var blueprint: MapTileData
var _spot_generator = SpotGenerator.new()
var _map_size: int
var _generation_manager: GridGenerationPipeline

func _process(_delta: float) -> void:
	if limit_areas_visualization:
		_visualize_limiter_areas()
	if map_visualization:
		_visualize()


## Generate basic road map [br][br]
## Add Limiter Areas to "GenerationAreas" node to customize generation [br][br]
## Clicking "Generate roads" will auto-initialize road generator [br][br]
## Changes tile "type" to "road" from "empty" when places road [br][br]
## Returns false on error
func run_generation(manager: GridGenerationPipeline) -> bool:
	if log_generation_steps:
		print("start road generation!")

	_generation_manager = manager
	generation_params.map_size = manager.blueprint.world_size
	_map_size = generation_params.map_size

	blueprint = manager.blueprint

	generation_params.generation_areas = _get_generation_areas()
	generation_params.prepare_generation_areas()

	_spot_generator.generate_spots(self)

	_spot_generator.cast_spots_to_blueprint()

	# later will be splitted and used outside of road generator
	#var autotiler: RoadAutotile = RoadAutotile.new()
#
	#if not autotiler.autotile_roads(manager):
		#return false

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


## Printing blueprint map data from given dictionary key for debug
func _print_to_console(key: String) -> void:
	if blueprint.data.is_empty():
		return
	print("printing '", key, "':")

	for y in _map_size:
		var output: String = ""
		for x in _map_size:
			if blueprint.data[Vector2i(x, y)].tile_type == TileInfo.Type.ROAD:
				if key == "type":
					output += " R"
					#output += " " + str(blueprint.data[Vector2i(x, y)].height)
				#if key == "rotation":
					#output += " " + str(blueprint[Vector2i(x, y)][key] / 90)
				#if key == "id":
					#if blueprint[Vector2i(x, y)][key] >= 0 and blueprint[Vector2i(x, y)][key] < 10:
						#output += " " + str(blueprint[Vector2i(x, y)][key])
					#else:
						#output += str(blueprint[Vector2i(x, y)][key])
			else:
				output += "  "
		print(output)


## Simple test visualization
func _visualize() -> void:
	if not _generation_manager:
		return
	var scale = _generation_manager.world_generation_params.tile_size
	# visualize spots
	for spot in _spot_generator.get_spots():
		spot.visualize(scale)

	# visualize roads
	for coord in blueprint.data.keys():
		if blueprint.data[coord].tile_type == TileInfo.Type.ROAD:
			DebugDraw3D.draw_box(
				Vector3(coord.x * scale, blueprint.data[coord].height, coord.y * scale),
					Quaternion.IDENTITY,
					Vector3(scale, 0.01, scale),
					Color.WHITE,
					false
				)


## visualization for better areas setup
func _visualize_limiter_areas():
	var scale = 1
	if _generation_manager:
		scale = _generation_manager.world_generation_params.tile_size

	for area in _get_generation_areas():
		area.visualize(scale)
