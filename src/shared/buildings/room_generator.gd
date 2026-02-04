@tool
class_name RoomGenerator
extends Node3D

@export_group("Initial Cells Data")
@export var initial_cells_start: Array[Vector3i] = []
@export var initial_cells_end: Array[Vector3i] = []

@export_group("Generation")
@export var generation_params: RoomGenerationParams
@export_tool_button("Generate Rooms") var generate_rooms_action = generate_rooms
@export_tool_button("Clear Rooms") var clear_rooms_action = clear_rooms


var initial_cells: Array[Cell] = []
var cells: Array[Cell] = []
var neighbors: Array[BorderInfo] = []

@onready var neighbors_generator: NeighborGenerator = $NeighborGenerator
@onready var cells_generator: CellGenerator = $CellGenerator
@onready var models_placer: ModelsPlacer = $ModelsPlacer


func generate_rooms() -> void:
	initial_cells.clear()
	for i in initial_cells_start.size():
		initial_cells.push_back(Cell.new(initial_cells_start[i], initial_cells_end[i]))


	cells_generator.generate_cells(self)
	neighbors_generator.generate_neighbors(self)
	models_placer.place_models(self)


func clear_rooms() -> void:
	cells = []
	neighbors = []
	models_placer.clear_models()
