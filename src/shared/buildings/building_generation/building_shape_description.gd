@tool
class_name BuildingShapeDescription
extends Node

@export var is_visible: bool = false
@onready var parent: BuildingGenerator = get_parent()

func get_cells() -> Array[Cell]:
	var cells: Array[Cell]
	cells.assign(find_children("", "BoxDescription", false, true).map(func(box): return box.to_cell()))
	return cells


func _enter_tree() -> void:
	parent = get_parent()
	parent.building_shape_description = self


func _process(_delta: float) -> void:
	if is_visible:
		for box in find_children("", "BoxDescription", false, true):
			box.draw_visualization(
				parent.global_position,
				Quaternion.from_euler(parent.global_rotation),
				parent.models_placer.gridmaps[0].cell_size
			)
