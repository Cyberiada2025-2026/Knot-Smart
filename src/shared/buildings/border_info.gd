@tool
class_name BorderInfo

var is_overlapping: bool = false
var overlap_start: Vector3i = Vector3i.ZERO
var overlap_end: Vector3i = Vector3i.ZERO
var neighbor_a: int = -1
var neighbor_b: int = -1
var edge_weight: int = 1
var is_open: bool = false
var is_outside: bool = false
var door_position: Vector3i = Vector3i.ZERO

func _to_string() -> String:
	return str(overlap_start) + str(overlap_end)

func size_x() -> int:
	return overlap_end.x - overlap_start.x

func size_y() -> int:
	return overlap_end.y - overlap_start.y

func size_z() -> int:
	return overlap_end.z - overlap_start.z

func center() -> Vector3:
	return Vector3(self.overlap_start.x + float(self.size_x())/2, self.overlap_start.y + float(self.size_y())/2, self.overlap_start.z + float(self.size_z())/2)

func size() -> Vector3i:
	return Vector3i(self.size_x(), self.size_y(), self.size_z())

func get_plane() -> Cell.Direction:
	if size_x() == 0:
		return Cell.Direction.X
	elif size_y() == 0:
		return Cell.Direction.Y
	else:
		return Cell.Direction.Z

func model_locations() -> Array:
	var arr = []
	var x_range = range(overlap_start.x, overlap_end.x) if size_x() > 0 else [overlap_start.x] 
	var y_range = range(overlap_start.y, overlap_end.y) if size_y() > 0 else [overlap_start.y]
	var z_range = range(overlap_start.z, overlap_end.z) if size_z() > 0 else [overlap_start.z] 

	for x in x_range:
		for y in y_range:
			for z in z_range:
				arr.push_back(Vector3i(x,y,z))
	return arr

func set_door_position() -> void:
	door_position = model_locations().filter(func(n): return n.y == overlap_start.y).pick_random()
				
static func create(start: Vector3i, end: Vector3i) -> BorderInfo:
	var bi = BorderInfo.new()
	bi.overlap_start = start
	bi.overlap_end = end
	return bi

