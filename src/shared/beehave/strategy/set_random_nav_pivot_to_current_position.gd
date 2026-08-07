class_name SetRandomNavPivotToCurrentPos
extends SetRandomNavPivotInterface

@export var transform_node: Node3D

var transform_present: bool = true


func _ready() -> void:
	if transform_node == null:
		printerr("No transform_node in SetRandomNavPivotToCurrentPos!!!")
		transform_present = false


func set_random_nav_target(actor: Node) -> void:
	if !transform_present:
		return
	actor.set_random_nav_target_near(transform_node.global_position)
