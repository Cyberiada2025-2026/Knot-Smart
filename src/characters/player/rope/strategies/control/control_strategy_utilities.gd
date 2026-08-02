class_name ControlStrategyUtilities

static func create_marker_from_unsafe_raycast(raycast_result: Dictionary, marker_mesh: Node3D) -> MeshInstance3D:
	return create_marker(raycast_result.collider, raycast_result.position, marker_mesh)

static func create_marker(collider, pos: Vector3, marker_mesh: Node3D) -> MeshInstance3D:
	var marker = marker_mesh.duplicate()
	collider.add_child(marker)
	marker.name = "PositionMarker"
	marker.owner = collider
	marker.global_position = pos
	return marker

static func create_rope(rope_params: RopeParams, selected_objects: Array[Node], markers: Array[MeshInstance3D]) -> Rope:
	var rope = Rope.new(rope_params, selected_objects, markers)
	return rope

static func create_marker_on_player(player: Node3D, marker_mesh: Node3D) -> MeshInstance3D:
	var player_height = player.get_node("CollisionShape3D").shape.height
	var local_placement = Vector3.UP * 0.5 * player_height
	var marker_pos = player.to_global(local_placement)

	return create_marker(player, marker_pos, marker_mesh)
