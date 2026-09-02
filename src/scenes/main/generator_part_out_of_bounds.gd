extends Area3D


func _on_body_entered(body: Node3D) -> void:
	prints(body, "entered despawn area")
	if body is GeneratorPart:
		prints("respawning generator part at", body.spawn_position)
		body.global_position = body.spawn_position
		body.linear_velocity = Vector3.ZERO

