@tool
class_name BuildingGenerator
extends Node3D

## Requires a [code]get_building_shape()[/code] method
## that returns an [code]Array[Cell][/code] of initial cells.
@export var building_shape_description: Resource
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
	if building_shape_description == null:
		push_warning("No building_shape_description provided.")
		return
	initial_cells = building_shape_description.get_building_shape()
	if initial_cells.size() == 0:
		push_warning("No initial shape provided.")
		return
	cells_generator.generate_cells(self)
	neighbors_generator.generate_neighbors(self)
	print(neighbors)
	for n in neighbors:
		prints(n.cell, n.door_position)
	models_placer.place_models(self)


func clear() -> void:
	cells = []
	neighbors = []
	models_placer.clear_models()
