@tool
class_name BuildingGenerator
extends Node3D

@export var building_cell_generator: Resource ## Requires a [code]get_building_cells()[/code] method that returns an [code]Array[Cell][/code] of initial cells.
@export var room_generation_params: RoomGenerationParams
@export_tool_button("Generate Building") var generate_building_action = generate_building
@export_tool_button("Clear") var clear_action = clear

var initial_cells: Array[Cell] = []
var cells: Array[Cell] = []
var neighbors: Array[BorderInfo] = []

@onready var neighbors_generator: NeighborGenerator = $NeighborGenerator
@onready var cells_generator: CellGenerator = $CellGenerator
@onready var models_placer: ModelsPlacer = $ModelsPlacer


func generate_building() -> void:
	initial_cells = building_cell_generator.get_building_cells()
	if initial_cells.size() == 0:
		push_warning("No initial_cells specified. No building generated. Make sure a building_cell_generator is set up.")
		return
	cells_generator.generate_cells(self)
	neighbors_generator.generate_neighbors(self)
	models_placer.place_models(self)


func clear() -> void:
	cells = []
	neighbors = []
	models_placer.clear_models()
