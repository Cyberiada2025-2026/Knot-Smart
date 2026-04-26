@tool
class_name BuildingGenerator
extends Node3D

@export var building_generation_params: BuildingGenerationParams
@export_tool_button("Generate Building") var generate_building_action = generate_building
@export_tool_button("Clear") var clear_action = clear

var gridmaps: Array[GridMap]
var initial_cells: Array[Cell] = []
var cells: Array[Cell] = []
var neighbors: Array[BorderInfo] = []

var building_shape_description: BuildingShapeDescription
var neighbors_generator: NeighborGenerator = NeighborGenerator.new(self)
var cells_generator: CellGenerator = CellGenerator.new(self)
var models_placer: ModelsPlacer = ModelsPlacer.new(self)
var nav_obstacle_generator: BuildingNavObstacleGenerator = BuildingNavObstacleGenerator.new(self)


func generate_building() -> void:
	clear()
	seed(building_generation_params.random_seed)
	if building_shape_description == null:
		push_warning("No building_shape_description provided.")
		return
	initial_cells = building_shape_description.get_cells()
	if initial_cells.size() == 0:
		push_warning("No initial shape provided.")
		return
	cells_generator.generate_cells()
	neighbors_generator.generate_neighbors()
	models_placer.place_models()

	nav_obstacle_generator.generate_navmesh_obstacles()
	if not building_generation_params.generate_rooms:
		generate_collision_shape()


func clear() -> void:
	cells = []
	neighbors = []

	models_placer.clear()
	nav_obstacle_generator.clear()
	for static_body in find_children("", "StaticBody3D"):
		static_body.queue_free()


func _get_configuration_warnings() -> PackedStringArray:
	if building_shape_description == null:
		return ["No building shape description provided."]
	return []


func generate_collision_shape() -> void:
	var static_body: StaticBody3D = StaticBody3D.new()
	add_child(static_body)
	for cell in initial_cells:
		var cell_collision_shape = CollisionShape3D.new()
		cell_collision_shape.shape = BoxShape3D.new()
		cell_collision_shape.shape.size = (
			Vector3(cell.size()) * building_generation_params.get_grid_size()
		)
		cell_collision_shape.position = cell.center() * building_generation_params.get_grid_size()
		static_body.add_child(cell_collision_shape)
