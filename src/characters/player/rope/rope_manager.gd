class_name RopeManager
extends Node3D

@export var rope_params = RopeParams.new()

var selected_objects: Array[Node] = []
var markers: Array[MeshInstance3D] = []
var sphere: MeshInstance3D = preload("uid://ymb8m1pspwfy").instantiate()

var active_rope: Rope = null


func _ready() -> void:
	add_child(sphere)


func _physics_process(_delta: float) -> void:
	sphere.hide()

	if not get_node("../PlayerCamera").get_view_type() == PlayerCamera.ViewType.FIRST_PERSON:
		return

	var raycast_result = UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()
	if not raycast_result.is_empty():
		sphere.position = raycast_result.position
		sphere.show()

		if raycast_result.collider.get_parent() is Rope:
			if Input.is_action_just_pressed("break_rope"):
				raycast_result.collider.get_parent().finish()
			elif Input.is_action_just_pressed("fuse"):
				raycast_result.collider.get_parent().fuse()
			else:
				return

	if not sphere.visible:
		return

	if Input.is_action_just_pressed("left_mouse"):
		if active_rope:
			active_rope.change_point(
				raycast_result.collider,
				_create_marker(raycast_result.collider, sphere.global_position)
			)
			active_rope = null

		else:
			place_marker_from_unsafe_raycast(raycast_result)
			place_marker_on_player()
			active_rope = create_rope()
			active_rope.finished.connect(_on_active_rope_finished)


func create_rope() -> Rope:
	var rope = Rope.new(rope_params, selected_objects, markers)
	add_child(rope)

	selected_objects = []
	markers = []
	return rope


func place_marker_from_unsafe_raycast(raycast_result):
	place_marker(raycast_result.collider, sphere.global_position)


func place_marker_on_player():
	var player = get_parent()
	var player_height = player.get_node("CollisionShape3D").shape.height
	var local_placement = Vector3.UP * 0.5 * player_height
	var marker_pos = player.to_global(local_placement)

	place_marker(player, marker_pos)


func place_marker(collider, pos):
	var marker = _create_marker(collider, pos)
	markers.append(marker)
	selected_objects.append(collider)


func _create_marker(collider, pos) -> MeshInstance3D:
	var marker = sphere.duplicate()
	collider.add_child(marker)
	marker.name = "PositionMarker"
	marker.owner = collider
	marker.global_position = pos
	return marker


func _on_active_rope_finished():
	active_rope = null
