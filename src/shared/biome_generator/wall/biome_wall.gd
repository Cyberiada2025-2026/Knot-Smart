@tool
class_name BiomeWall
extends CSGCombiner3D

@export_category("scenes")
@export
var simple_wall_scene: PackedScene = preload("res://shared/biome_generator/wall/wall_simple.tscn")

var adjacent_biomes: Array[Biome] = []
var start_point: Vector3
var end_point: Vector3


func create_wall(start: Vector2, end: Vector2) -> void:
	self.start_point = Vector3(start.x, 0, start.y)
	self.end_point = Vector3(end.x, 0, end.y)
	_make_simple_wall()


func _make_simple_wall() -> void:
	var box: CSGBox3D = simple_wall_scene.instantiate()
	self.add_child(box)
	box.owner = self.owner
	box.global_position = (start_point + end_point) / 2
	box.rotate_y(get_wall_angle())
	box.size.x = start_point.distance_to(end_point)


func add_biome(biome: Biome) -> void:
	if adjacent_biomes.find(biome) == -1:
		adjacent_biomes.append(biome)
		biome.add_wall(self)


func remove_biome(biome: Biome) -> void:
	adjacent_biomes.erase(biome)
	try_to_remove()


func try_to_remove() -> void:
	if adjacent_biomes.is_empty():
		self.queue_free()


func get_wall_angle() -> float:
	return -atan2(end_point.z - start_point.z, end_point.x - start_point.x)
