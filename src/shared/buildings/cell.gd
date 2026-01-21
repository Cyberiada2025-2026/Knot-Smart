@tool
class_name Cell
extends Resource

enum Direction {
	Y,
	X,
	Z,
}

@export var start: Vector3i = Vector3i(0, 0, 0)
@export var end: Vector3i = Vector3i(1, 1, 1)


static func create(s: Vector3i, e: Vector3i) -> Cell:
	var cell = Cell.new()
	cell.start = s
	cell.end = e
	return cell


func _to_string() -> String:
	return "start: " + str(self.start) + ", end: " + str(self.end)


func split(gen_params: RoomGenerationParams) -> Array[Cell]:
	var direction = self.get_split_direction(gen_params)

	var e1: Vector3i
	var s2: Vector3i

	match direction:
		Direction.X:
			var split_point = randi_range(
				gen_params.min_room_size.x, self.size_x() - gen_params.min_room_size.x
			)
			e1 = Vector3i(self.start.x + split_point, self.end.y, self.end.z)
			s2 = Vector3i(self.start.x + split_point, self.start.y, self.start.z)
		Direction.Y:
			var split_point = randi_range(
				gen_params.min_room_size.y, self.size_y() - gen_params.min_room_size.y
			)
			e1 = Vector3i(self.end.x, self.start.y + split_point, self.end.z)
			s2 = Vector3i(self.start.x, self.start.y + split_point, self.start.z)
		Direction.Z:
			var split_point = randi_range(
				gen_params.min_room_size.z, self.size_z() - gen_params.min_room_size.z
			)
			e1 = Vector3i(self.end.x, self.end.y, self.start.z + split_point)
			s2 = Vector3i(self.start.x, self.start.y, self.start.z + split_point)

	var c1 = Cell.create(self.start, e1)
	var c2 = Cell.create(s2, self.end)

	return [c1, c2]


func get_split_direction(gen_params: RoomGenerationParams) -> Cell.Direction:
	var y_split_chance = randi_range(0, 2)
	if (
		(size_y() > gen_params.min_room_size.y and y_split_chance != 0)
		or (
			self.size_x() <= gen_params.min_room_size.x
			&& self.size_z() <= gen_params.min_room_size.z
		)
	):
		return Direction.Y

	if self.size_x() <= gen_params.min_room_size.x:
		return Direction.Z
	if self.size_z() <= gen_params.min_room_size.z:
		return Direction.X

	var randomizer = randi_range(
		-gen_params.room_split_direction_randomizer, gen_params.room_split_direction_randomizer
	)

	var diff = self.size_x() - self.size_z()
	var randomized_diff = diff + randomizer

	if randomized_diff <= 0:
		return Direction.Z
	return Direction.X


func get_neighbor_info(other: Cell) -> BorderInfo:
	var overlap_xy = self.check_overlap_xy(other)
	var overlap_xz = self.check_overlap_xz(other)
	var overlap_yz = self.check_overlap_yz(other)
	if self.start.x == other.end.x or other.start.x == self.end.x:
		if overlap_yz.is_overlapping:
			var overlap_x = self.start.x if self.start.x == other.end.x else other.start.x
			overlap_yz.overlap_start.x = overlap_x
			overlap_yz.overlap_end.x = overlap_x
			return overlap_yz
	if self.start.y == other.end.y or other.start.y == self.end.y:
		if overlap_xz.is_overlapping:
			var overlap_y = self.start.y if self.start.y == other.end.y else other.start.y
			overlap_xz.overlap_start.y = overlap_y
			overlap_xz.overlap_end.y = overlap_y
			return overlap_xz
	if self.start.z == other.end.z or other.start.z == self.end.z:
		if overlap_xy.is_overlapping:
			var overlap_z = self.start.z if self.start.z == other.end.z else other.start.z
			overlap_xy.overlap_start.z = overlap_z
			overlap_xy.overlap_end.z = overlap_z
			return overlap_xy
	return BorderInfo.new()


func size_x() -> int:
	return end.x - start.x


func size_y() -> int:
	return end.y - start.y


func size_z() -> int:
	return end.z - start.z


func area() -> int:
	return size_x() * size_z()


func center() -> Vector3:
	return Vector3(
		self.start.x + float(self.size_x()) / 2,
		self.start.y + float(self.size_y()) / 2,
		self.start.z + float(self.size_z()) / 2
	)


func size() -> Vector3i:
	return Vector3i(self.size_x(), self.size_y(), self.size_z())


func overlaps(s0, e0, s1, e1) -> bool:
	return e0 - s1 >= 1 and e1 - s0 >= 1


func check_overlap_xy(other: Cell) -> BorderInfo:
	var info = BorderInfo.new()
	info.is_overlapping = (
		overlaps(self.start.x, self.end.x, other.start.x, other.end.x)
		and overlaps(self.start.y, self.end.y, other.start.y, other.end.y)
	)
	info.overlap_start = Vector3i(
		maxi(self.start.x, other.start.x), maxi(self.start.y, other.start.y), 0
	)
	info.overlap_end = Vector3i(min(self.end.x, other.end.x), mini(self.end.y, other.end.y), 0)
	return info


func check_overlap_xz(other: Cell) -> BorderInfo:
	var info = BorderInfo.new()
	info.is_overlapping = (
		overlaps(self.start.x, self.end.x, other.start.x, other.end.x)
		and overlaps(self.start.z, self.end.z, other.start.z, other.end.z)
	)
	info.overlap_start = Vector3i(
		maxi(self.start.x, other.start.x), 0, maxi(self.start.z, other.start.z)
	)
	info.overlap_end = Vector3i(mini(self.end.x, other.end.x), 0, mini(self.end.z, other.end.z))
	return info


func check_overlap_yz(other: Cell) -> BorderInfo:
	var info = BorderInfo.new()
	info.is_overlapping = (
		overlaps(self.start.y, self.end.y, other.start.y, other.end.y)
		and overlaps(self.start.z, self.end.z, other.start.z, other.end.z)
	)
	info.overlap_start = Vector3i(
		0, maxi(self.start.y, other.start.y), maxi(self.start.z, other.start.z)
	)
	info.overlap_end = Vector3i(0, mini(self.end.y, other.end.y), mini(self.end.z, other.end.z))
	return info


func get_all_borders() -> Array[BorderInfo]:
	return [
		BorderInfo.create(start, Vector3i(start.x, end.y, end.z)),
		BorderInfo.create(start, Vector3i(end.x, start.y, end.z)),
		BorderInfo.create(start, Vector3i(end.x, end.y, start.z)),
		BorderInfo.create(Vector3i(end.x, start.y, start.z), end),
		BorderInfo.create(Vector3i(start.x, end.y, start.z), end),
		BorderInfo.create(Vector3i(start.x, start.y, end.z), end),
	]
