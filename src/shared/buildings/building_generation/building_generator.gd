@tool
class_name BuildingGenerator
extends Node3D

@export var room_generation_params: RoomGenerationParams
@export_tool_button("Generate Building") var generate_building_action = generate_building
@export_tool_button("Clear") var clear_action = clear

var initial_cells: Array[Cell] = []
var cells: Array[Cell] = []
var neighbors: Array[BorderInfo] = []

var building_shape_description: BuildingShapeDescription
var neighbors_generator: NeighborGenerator
var cells_generator: CellGenerator
var models_placer: ModelsPlacer


func generate_building() -> void:
	seed(room_generation_params.random_seed)
	get_parent().set_editable_instance(self, true)
	if building_shape_description == null:
		push_warning("No building_shape_description provided.")
		return
	initial_cells = building_shape_description.get_cells()
	if initial_cells.size() == 0:
		push_warning("No initial shape provided.")
		return
	cells_generator.generate_cells(self)
	neighbors_generator.generate_neighbors(self)
	models_placer.place_models(self)

	generate_navmesh_obstacle()


func clear() -> void:
	cells = []
	neighbors = []
	models_placer.clear_models()

	
func generate_navmesh_obstacle() -> void:
	var outline = get_building_outline()

	var obstacle = NavigationObstacle3D.new()
	obstacle.affect_navigation_mesh = true
	obstacle.avoidance_enabled = false
	obstacle.height = 30.0
	obstacle.vertices = outline

	add_child(obstacle)
	obstacle.owner = get_tree().edited_scene_root


func get_building_outline() -> PackedVector3Array:
	return PackedVector3Array([Vector3(-5, 0, -5), Vector3(5, 0, -5), Vector3(5, 0, 5), Vector3(-5, 0, 5)])


func _get_configuration_warnings() -> PackedStringArray:
	if neighbors_generator and cells_generator and models_placer:
		return []
	return [
		"Child nodes are missing. Instantiate BuildingGenerator through scene or add them manually."
	]
