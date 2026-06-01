class_name ChangingPart
extends Node3D

@export var before_change: Node3D
@export var after_change: Node3D

func _ready() -> void:
	if before_change == null or after_change == null:
		return
	before_change.visible = true
	if before_change is CSGShape3D:
		after_change.use_collision = true

	after_change.visible = false
	if after_change is CSGShape3D:
		after_change.use_collision = false

func _on_change_part(_node: Node) -> void:
	if before_change == null or after_change == null:
		return
	before_change.visible = false
	if before_change is CSGShape3D:
		before_change.use_collision = false

	after_change.visible = true
	if after_change is CSGShape3D:
		after_change.use_collision = true
