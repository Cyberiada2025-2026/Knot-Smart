@tool
class_name BoxShape
extends Node

@export_group("Data")
@export var start: Vector3i
@export var end: Vector3i

@export_group("Visualization")
@export var is_visible: bool = false

@export_group("Other")
@export var grid_scale: Vector3 = Vector3(2, 2.8, 2)

func to_cell() -> Cell:
	return Cell.new(start, end)

func _draw() -> void:
	pass
