class_name SetRandomNavPivotToOrigin
extends Node

@export var transform_node: Node3D


func _ready() -> void:
	var random_nav: SetRandomNavTarget = get_node("..")
	if random_nav == null:
		printerr("No SetRandomNavTarget found in Parent!!!")
		return
	random_nav.random_point_around_player = false
	random_nav.random_point_pivot = transform_node.global_position
