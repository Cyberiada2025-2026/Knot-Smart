@tool
extends RefCounted

#single spot for building placement and roads, uses parts of cell.gd code from room generator
class_name Spot

@export var start: Vector2i = Vector2i.ZERO
@export var end: Vector2i = Vector2i.ZERO
	
var neighbors_up: Array[Spot] = []
var neighbors_down: Array[Spot] = []
var neighbors_left: Array[Spot] = []
var neighbors_right: Array[Spot] = []


func size_x() -> int:
	return end.x - start.x
	

func size_y() -> int:
	return end.y - start.y
	

func center() -> Vector3:
	return Vector3(
		self.start.x + float(self.size_x()) / 2, 1, self.start.y + float(self.size_y()) / 2
	)
	

func overlaps(other: Spot) -> bool:
	if (
		self.start.x < other.end.x 
		and other.start.x < self.end.x
		and self.start.y < other.end.y 
		and other.start.y < self.end.y
	):
		return true
		
	return false
	
	
func split_x(min_spot_size: Vector2i) -> Spot:
	var split_position = randi_range(start.x + min_spot_size.x, end.x - min_spot_size.x)
	var new_spot: Spot = create(Vector2(split_position, start.y), end)
	self.end.x = split_position 
	
	return new_spot


func split_y(min_spot_size: Vector2i) -> Spot:
	var split_position = randi_range(start.y + min_spot_size.y, end.y - min_spot_size.y)
	var new_spot: Spot = create(Vector2(start.x, split_position), end)
	self.end.y = split_position
	
	return new_spot
	

func cast_on_map(map, generation_params: RoadGenerationParams):
	for i in range(start.x, end.x + 1):
		map[i][start.y] = generation_params.ROAD
		map[i][end.y] = generation_params.ROAD
		
	for i in range(start.y, end.y + 1):
		map[start.x][i] = generation_params.ROAD
		map[end.x][i] = generation_params.ROAD
	

func visualize(visualization_container: Node3D, object_name: String):
	var box = MeshInstance3D.new()
	box.mesh = BoxMesh.new()
	box.mesh.size = Vector3(size_x(), 1, size_y())
	box.position = center()
	box.name = object_name

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf(), 1.0)
	box.mesh.material = material
	
	visualization_container.add_child(box)
	box.owner = visualization_container.owner
	
	
static func create(spot_start: Vector2i, spot_end: Vector2i):
	var sp = Spot.new()
	sp.start = spot_start
	sp.end = spot_end
	return sp
	
	
static func create_from_center(center_position: Vector2i, spot_radius: Vector2i):
	var sp = Spot.new()
	sp.start = Vector2i(center_position.x - spot_radius.x, center_position.y - spot_radius.y)
	sp.end = Vector2i(center_position.x + spot_radius.x, center_position.y + spot_radius.y)
	return sp
