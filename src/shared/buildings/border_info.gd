@tool
class_name BorderInfo

var is_overlapping: bool = false
var cell: Cell = Cell.new()
var neighbor_a: Cell = null
var neighbor_b: Cell = null
var edge_weight: int = 1
var is_open: bool = false
var door_position: Vector3i = Vector3i.ZERO


func _to_string() -> String:
	return str(cell)


func model_locations() -> Array:
	var arr = []

	for x in cell.range(Vector3i.Axis.AXIS_X):
		for y in cell.range(Vector3i.Axis.AXIS_Y):
			for z in cell.range(Vector3i.Axis.AXIS_Z):
				arr.push_back(Vector3i(x, y, z))
	return arr


func set_door_position() -> void:
	door_position = model_locations().filter(func(n): return n.y == cell.start.y).pick_random()


func _init(start: Vector3i = Vector3i(0, 0, 0), end: Vector3i = Vector3i(0, 0, 0)):
	cell = Cell.new(start, end)
