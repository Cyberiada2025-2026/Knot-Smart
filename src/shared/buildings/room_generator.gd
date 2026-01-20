@tool
extends Node

@export var neighbors_generator: NeighborGenerator
@export var cells_generator: CellGenerator
@export var models_placer: ModelsPlacer

@export_group("Generation")
@export var generation_params: RoomGenerationParams
@export_tool_button("Generate Rooms") var generate_rooms_action = generate_rooms
@export_tool_button("Generate Doors") var generate_doors_action = generate_neighbors
@export_tool_button("Place Models") var place_models_action = place_models
@export_group("Visualization")

func place_models() -> void:
	models_placer.place_models(_neighbors, _cells, generation_params)

func generate_neighbors() -> void:
	_neighbors = neighbors_generator.generate_neighbors(_cells)

func generate_rooms() -> void:
	initial_cells.clear()
	initial_cells.push_back(Cell.create(Vector3i(0,0,0), Vector3i(5,2,5)))
	initial_cells.push_back(Cell.create(Vector3i(5,0,2), Vector3i(7,1,5)))
	initial_cells.push_back(Cell.create(Vector3i(5,0,0), Vector3i(10,4,2)))

	_cells = cells_generator.generate_rooms(initial_cells, generation_params)


var initial_cells: Array[Cell] = []
var _cells: Array[Cell] = []
var _neighbors: Array[BorderInfo] = []





