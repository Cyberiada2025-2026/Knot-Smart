@tool
class_name BuildingGenerator
extends Node3D

const NAV_MESH_OBSTACLE_HEIGHT: float = 30.0

@export var mesh_library: MeshLibrary
@export var grid_cell_size: Vector3 = Vector3.ONE
@export var can_enter: bool = true
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
	clear()
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

	generate_navmesh_obstacles()
	if not can_enter:
		generate_collision_shape()


func clear() -> void:
	cells = []
	neighbors = []
	models_placer.clear_models()
	for obstacle in find_children("", "NavigationObstacle3D"):
		obstacle.queue_free()
	for static_body in find_children("", "StaticBody3D"):
		static_body.queue_free()
	cells_generator = CellGenerator.new(self)


func generate_navmesh_obstacles() -> void:
	var scaling: Vector3 = models_placer.gridmaps[0].cell_size

	for cell in initial_cells:
		var outline = cell.get_base_vertices(scaling)

		var obstacle = NavigationObstacle3D.new()
		obstacle.affect_navigation_mesh = true
		obstacle.avoidance_enabled = false
		obstacle.height = NAV_MESH_OBSTACLE_HEIGHT
		obstacle.vertices = outline

		add_child(obstacle)
		obstacle.owner = get_tree().edited_scene_root


func _get_configuration_warnings() -> PackedStringArray:
	if neighbors_generator and cells_generator and models_placer:
		return []
	return [
		"Child nodes are missing. Instantiate BuildingGenerator through scene or add them manually."
	]

func generate_collision_shape() -> void:
	var static_body: StaticBody3D = StaticBody3D.new()
	add_child(static_body)
	static_body.owner = get_tree().edited_scene_root
	for cell in initial_cells:
		var cell_collision_shape = CollisionShape3D.new()
		cell_collision_shape.shape = BoxShape3D.new()
		cell_collision_shape.shape.size = Vector3(cell.size()) * grid_cell_size
		cell_collision_shape.position = cell.center() * grid_cell_size 
		static_body.add_child(cell_collision_shape)
		cell_collision_shape.owner = get_tree().edited_scene_root

		
