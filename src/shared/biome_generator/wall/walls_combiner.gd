extends CSGCombiner3D

class_name WallsCombiner

@export var entance_scene: PackedScene = preload("res://shared/biome_generator/wall/wall_entrance.tscn")

func add_entrance(coordinates: Vector3) -> void:
	var entrance: Node3D = entance_scene.instantiate()
	self.add_child(entrance)
	entrance.global_position = coordinates
