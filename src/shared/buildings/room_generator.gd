@tool
extends Node3D

@export var generation_params: RoomGenerationParams
@export_tool_button("Generate Rooms") var generate_rooms_action = generate_rooms

var initial_cells: Array[Cell] = [
	Cell.create(Vector3i(0, 0, 0), Vector3i(5, 2, 5)),
	Cell.create(Vector3i(5, 0, 2), Vector3i(7, 1, 5)),
	Cell.create(Vector3i(5, 0, 0), Vector3i(10, 4, 2)),
]
var _cells: Array[Cell] = []
var _neighbors: Array[BorderInfo] = []

@onready var neighbors_generator: NeighborGenerator = $NeighborGenerator
@onready var cells_generator: CellGenerator = $CellGenerator
@onready var models_placer: ModelsPlacer = $ModelsPlacer


func place_models() -> void:
	models_placer.place_models(_neighbors, _cells, generation_params)


func generate_neighbors() -> void:
	_neighbors = neighbors_generator.generate_neighbors(_cells)


func generate_rooms() -> void:
	_cells = cells_generator.generate_cells(initial_cells, generation_params)
	_neighbors = neighbors_generator.generate_neighbors(_cells)
	models_placer.place_models(_neighbors, _cells, generation_params)
