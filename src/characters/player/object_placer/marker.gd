class_name Marker
extends Area3D

var allows_placement = false

@onready var marker_allowing_placement = $MarkerAllowingPlacement
@onready var marker_colliding = $MarkerColliding
@onready var collision_shape = $CollisionShape3D

func resize(size: Vector3) -> void:
	marker_allowing_placement.mesh.size = size
	marker_colliding.mesh.size = size
	collision_shape.shape.size = size


func get_half_height() -> float:
	return marker_allowing_placement.mesh.size.y / 2


func update_state() -> void:
	var bodies = get_overlapping_bodies()
	if not bodies.is_empty():
		allows_placement = false
		marker_allowing_placement.hide()
		marker_colliding.show()
		return
	allows_placement = true
	marker_allowing_placement.show()
	marker_colliding.hide()
