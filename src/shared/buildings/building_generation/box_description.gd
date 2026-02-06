@tool
class_name BoxDescription
extends Node

@export_group("Data")
@export var start: Vector3i
@export var size: Vector3i:
	set(value):
		size = value.clamp(Vector3.ZERO, abs(value))

@export_group("Other")
@export var debug_color: Color


func to_cell() -> Cell:
	return Cell.new(start, start + size)


func draw_visualization(
	global_position: Vector3, rotation: Quaternion, grid_scale: Vector3
) -> void:
	var rotation_axis = rotation.get_axis() if rotation.get_angle() != 0 else Vector3.UP
	var position: Vector3 = (
		global_position
		+ (start as Vector3 * grid_scale).rotated(rotation_axis, rotation.get_angle())
	)
	DebugDraw3D.draw_box(position, rotation, size as Vector3 * grid_scale, debug_color)
