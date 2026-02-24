@tool
extends Resource

#single spot for building placement and roads, uses parts of cell.gd code from room generator
class_name Spot

# start coordinates should be always smaller than end coordinates
@export var start: Vector2i = Vector2i.ZERO
@export var end: Vector2i = Vector2i.ONE

func _init(_start: Vector2i = Vector2i.ZERO, _end: Vector2i = Vector2i.ONE) -> void:
	# ensure that start coordinates are smaller than end
	start = Vector2i(mini(_start.x, _end.x), mini(_start.y, _end.y))
	end = Vector2i(maxi(_start.x, _end.x), maxi(_start.y, _end.y))
	
	
func size() -> Vector2i:
	return end - start
	
	
func area() -> int:
	return size().x * size().y

func center() -> Vector3:
	return Vector3(
		self.start.x + float(self.size().x) / 2, 1, self.start.y + float(self.size().y) / 2
	)
	

func overlaps(other: Spot) -> bool:
	return (
		self.start.x < other.end.x 
		and other.start.x < self.end.x
		and self.start.y < other.end.y 
		and other.start.y < self.end.y
	)
	
	
func split_x(min_spot_size: Vector2i) -> Spot:
	var split_position = randi_range(start.x + min_spot_size.x, end.x - min_spot_size.x)
	var new_spot: Spot = Spot.new(Vector2(split_position, start.y), end)
	self.end.x = split_position 
	
	return new_spot


func split_y(min_spot_size: Vector2i) -> Spot:
	var split_position = randi_range(start.y + min_spot_size.y, end.y - min_spot_size.y)
	var new_spot: Spot = Spot.new(Vector2(start.x, split_position), end)
	self.end.y = split_position
	
	return new_spot
	

func cast_on_blueprint(blueprint: Dictionary):
	for i in range(start.x, end.x + 1):
		blueprint[Vector2i(i, start.y)]["type"] = "road"
		blueprint[Vector2i(i, end.y)]["type"] = "road"
		
	for i in range(start.y, end.y + 1):
		blueprint[Vector2i(start.x, i)]["type"] = "road"
		blueprint[Vector2i(end.x, i)]["type"] = "road"
	
	# zjebane
	#for axis in 2:
		#for i in range(start[axis], end[axis] + 1):
			#blueprint[Vector2i(i, start[(axis + 1) % 2])]["type"] = "road"
			#blueprint[Vector2i(i, end[(axis + 1) % 2])]["type"] = "road"


func visualize(visualization_container: Node3D, object_name: String):
	var box = MeshInstance3D.new()
	box.mesh = BoxMesh.new()
	box.mesh.size = Vector3(self.size().x, 1, self.size().y)
	box.position = center()
	box.name = object_name

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(randf(), randf(), randf(), 1.0)
	box.mesh.material = material
	
	visualization_container.add_child(box)
	box.owner = visualization_container.owner
