@tool
extends Node3D

@export var room_generator: RoomGenerator

@export_group("Initial Cells Data")
@export var initial_cells_start: Array[Vector3i] = []
@export var initial_cells_end: Array[Vector3i] = []

@export_tool_button("Generate Rooms") var generate_rooms_action = generate_rooms

func generate_rooms() -> void:
	room_generator.initial_cells.clear()
	for i in initial_cells_start.size():
		room_generator.initial_cells.push_back(Cell.new(initial_cells_start[i], initial_cells_end[i]))

	room_generator.generate_rooms()

