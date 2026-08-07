class_name SetRandomNavPivotToOrigin
extends SetRandomNavPivotInterface

@export var transform_node: Node3D

var origin_position: Vector3

var transform_present: bool = true


func _ready() -> void:
	if transform_node == null:
		printerr("No transform_node in SetRandomNavPivotToOrigin!!!")
		transform_present = false
		return
	origin_position = transform_node.global_position


func set_random_nav_target(actor: Node) -> void:
	if !transform_present:
		return
	actor.set_random_nav_target_near(origin_position)
