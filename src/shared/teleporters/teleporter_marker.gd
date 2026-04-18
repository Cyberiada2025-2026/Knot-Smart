class_name TeleporterMarker
extends Area3D

var allows_teleporter_placement = false

@onready var marker_allowing_placement = $MarkerAllowingPlacement
@onready var marker_colliding = $MarkerColliding

func update_state(raycasted_body: Node3D) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body != raycasted_body:
			allows_teleporter_placement = false
			marker_allowing_placement.hide()
			marker_colliding.show()
			return

	allows_teleporter_placement = true
	marker_allowing_placement.show()
	marker_colliding.hide()
