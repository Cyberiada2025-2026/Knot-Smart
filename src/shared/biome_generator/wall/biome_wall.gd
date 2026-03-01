extends Node3D

class_name BiomeWall

@export var path: Path3D
@export var path_follow: PathFollow3D

@export var collumn_scene: PackedScene
@export_category("curve")
@export var bake_interval: float = 1
@export var distance_between_columns: float = 1.0
@export var max_points_in_middle: int = 0
@export var random_in_out_x_vector: float = 10.0
@export var random_in_out_z_vector: float = 10.0

var adjacent_biomes: Array[Biome] = []
var start_point: Vector3
var end_point: Vector3

func create_wall(start: Vector2, end: Vector2) -> void:
	self.start_point = Vector3(start.x, 0, start.y)
	self.end_point = Vector3(end.x, 0, end.y)
	_set_curve()
	_make_collumns()

func _set_curve() -> void:
	path.curve = Curve3D.new()
	path.curve.bake_interval = bake_interval
	var points_in_middle: int = randi()%(max_points_in_middle+1)
	path.curve.add_point(start_point, Vector3.ZERO, Vector3(randf()*random_in_out_x_vector, 0, randf()*random_in_out_z_vector))
	for i in range(points_in_middle):
		var point: Vector3 = start_point.move_toward(end_point, start_point.distance_to(end_point)*(i+1)/(points_in_middle+1))
		path.curve.add_point(point, Vector3(randf()*random_in_out_x_vector, 0, randf()*random_in_out_z_vector), Vector3(randf()*random_in_out_x_vector, 0, randf()*random_in_out_z_vector))
	path.curve.add_point(end_point, Vector3(randf()*random_in_out_x_vector, 0, randf()*random_in_out_z_vector), Vector3.ZERO)

func _make_collumns() -> void:
	while path_follow.progress_ratio < 1:
		var collumn: Node3D = collumn_scene.instantiate()
		self.add_child(collumn)
		collumn.global_position = path_follow.global_position
		path_follow.progress += distance_between_columns

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
