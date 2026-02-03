@tool
class_name RoomGenerator
extends Node3D

@export var generation_params: RoomGenerationParams
@export_tool_button("Generate Rooms") var generate_rooms_action = generate_rooms
@export_tool_button("Clear Rooms") var clear_rooms_action = clear_rooms

var initial_cells: Array[Cell] = [
	Cell.new(Vector3i(0, 0, 0), Vector3i(5, 2, 5)),
	Cell.new(Vector3i(5, 0, 2), Vector3i(7, 1, 5)),
	Cell.new(Vector3i(5, 0, 0), Vector3i(10, 4, 2)),
]
var cells: Array[Cell] = []
var neighbors: Array[BorderInfo] = []

@onready var neighbors_generator: NeighborGenerator = $NeighborGenerator
@onready var cells_generator: CellGenerator = $CellGenerator
@onready var models_placer: ModelsPlacer = $ModelsPlacer


func generate_rooms() -> void:
	cells_generator.generate_cells(self)
	neighbors_generator.generate_neighbors(self)
	models_placer.place_models(self)


func clear_rooms() -> void:
	cells = []
	neighbors = []
	models_placer.clear_models()
