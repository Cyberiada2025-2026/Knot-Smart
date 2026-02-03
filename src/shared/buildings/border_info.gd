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
	var x_range = range(cell.start.x, cell.end.x) if cell.size_x() > 0 else [cell.start.x]
	var y_range = range(cell.start.y, cell.end.y) if cell.size_y() > 0 else [cell.start.y]
	var z_range = range(cell.start.z, cell.end.z) if cell.size_z() > 0 else [cell.start.z]

	for x in x_range:
		for y in y_range:
			for z in z_range:
				arr.push_back(Vector3i(x, y, z))
	return arr


func set_door_position() -> void:
	door_position = model_locations().filter(func(n): return n.y == cell.start.y).pick_random()


func _init(start: Vector3i = Vector3i(0,0,0), end: Vector3i = Vector3i(0,0,0)):
	cell = Cell.new(start, end)

