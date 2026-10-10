class_name SetRandomNavPivotToOrigin
extends SetRandomNavPivotInterface

@export var transform_node: Node3D

var origin_position: Vector3


func _ready() -> void:
	origin_position = transform_node.global_position


func set_random_nav_target(actor: Node) -> void:
	actor.set_random_nav_target_near(origin_position)
