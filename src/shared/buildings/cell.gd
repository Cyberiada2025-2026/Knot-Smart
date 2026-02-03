@tool
class_name Cell
extends Resource

@export var start: Vector3i = Vector3i(0, 0, 0)  ## 1 unit = 1 cell in a grid. Cell size can be modified in GridMap properties
@export var end: Vector3i = Vector3i(1, 1, 1)  ## 1 unit = 1 cell in a grid. Cell size can be modified in GridMap properties
var id: int = 0

const DIFFERENT_FLOOR_EDGE_WEIGHT_MODIFIER: int = 2
const HALLWAY_EDGE_WEIGHT_MODIFIER: int = -1


func _init(_start: Vector3i = Vector3i(0, 0, 0), _end: Vector3i = Vector3i(1, 1, 1)) -> void:
	start = _start
	end = _end


func _to_string() -> String:
	return "start: " + str(self.start) + ", end: " + str(self.end)


func range(dir: Utils.Axis) -> Array:
	return range(start[dir], end[dir]) if size()[dir] > 0 else [start[dir]]


func is_hallway() -> bool:
	return (self.size().x == 1 or self.size().y == 1) and self.area() != 1


func is_larger_than(dim: Vector3i) -> bool:
	return (
		(self.size().y > dim.y)
		or (self.size().x > dim.x or self.size().z > dim.x)
		or (self.size().x > dim.z or self.size().z > dim.z)
	)


func get_neighbor_info(other: Cell) -> BorderInfo:
	var overlap = self.get_overlap(other)

	overlap.neighbor_a = self
	overlap.neighbor_b = other

	if self.center().y != other.center().y:
		overlap.edge_weight += DIFFERENT_FLOOR_EDGE_WEIGHT_MODIFIER
	if self.is_hallway() or other.is_hallway():
		overlap.edge_weight += HALLWAY_EDGE_WEIGHT_MODIFIER

	return overlap


func size() -> Vector3i:
	return end - start


func max_side_length() -> int:
	return max(size().x, size().z)


func area() -> int:
	return size().x * size().z


func center() -> Vector3:
	return Vector3(
		self.start.x + float(self.size().x) / 2,
		self.start.y + float(self.size().y) / 2,
		self.start.z + float(self.size().z) / 2
	)


func overlaps(other: Cell, dir: Utils.Axis) -> bool:
	return end[dir] - other.start[dir] >= 0 and other.end[dir] - start[dir] >= 0


func get_overlap(other: Cell) -> BorderInfo:
	var info = BorderInfo.new()
	for axis in Utils.Axis.values():
		if not overlaps(other, axis):
			return info

	info.cell = Cell.new(
		Vector3i(
			maxi(self.start.x, other.start.x),
			maxi(self.start.y, other.start.y),
			maxi(self.start.z, other.start.z)
		),
		Vector3i(
			mini(self.end.x, other.end.x),
			mini(self.end.y, other.end.y),
			mini(self.end.z, other.end.z)
		)
	)
	info.is_overlapping = true

	return info


func get_all_borders() -> Array[BorderInfo]:
	return [
		BorderInfo.new(start, Vector3i(start.x, end.y, end.z)),
		BorderInfo.new(start, Vector3i(end.x, start.y, end.z)),
		BorderInfo.new(start, Vector3i(end.x, end.y, start.z)),
		BorderInfo.new(Vector3i(end.x, start.y, start.z), end),
		BorderInfo.new(Vector3i(start.x, end.y, start.z), end),
		BorderInfo.new(Vector3i(start.x, start.y, end.z), end),
	]
