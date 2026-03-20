class_name RopeManager
extends Node3D

enum State { SELECT_FIRST, SELECT_SECOND }

const RADIUS = 0.1

@export var rope_params = RopeParams.new()

var state = State.SELECT_FIRST
var selected_objects: Array[Node] = []
var markers: Array[MeshInstance3D] = []
var sphere: MeshInstance3D


func _ready() -> void:
	sphere = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.set_radius(RADIUS)
	mesh.set_height(2 * RADIUS)
	sphere.set_mesh(mesh)
	add_child(sphere)


func _physics_process(_delta: float) -> void:
	sphere.hide()

	var raycast_result

	if get_node("../PlayerPhysics/PlayerCamera").get_view_type() == PlayerCamera.ViewType.FIRST_PERSON:
		raycast_result = UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()

		if not raycast_result.is_empty():
			sphere.position = raycast_result.position
			sphere.show()

			if raycast_result.collider.get_parent() is Rope:
				if Input.is_action_just_pressed("break_rope"):
					raycast_result.collider.get_parent().finish()

				elif Input.is_action_just_pressed("fuse"):
					raycast_result.collider.get_parent().fuse()

	match state:
		State.SELECT_FIRST:
			if Input.is_action_just_pressed("left_mouse") and sphere.visible:
				place_marker_from_unsafe_raycast(raycast_result)
				state = State.SELECT_SECOND

		State.SELECT_SECOND:
			if Input.is_action_just_pressed("left_mouse") and sphere.visible:
				place_marker_from_unsafe_raycast(raycast_result)
				create_rope()
				state = State.SELECT_FIRST

			elif Input.is_action_just_pressed("select_player"):
				place_marker_on_player()
				create_rope()
				state = State.SELECT_FIRST


func create_rope():
	var positions: Array[Vector3] = []
	for marker in markers:
		positions.append(marker.global_position)
	var rope = Rope.new(rope_params, selected_objects, positions)
	add_child(rope)

	selected_objects = []
	for marker in markers:
		marker.queue_free()
	markers = []


func place_marker_from_unsafe_raycast(raycast_result):
	place_marker(raycast_result.collider, sphere.global_position)


func place_marker_on_player():
	var player = get_node("../PlayerPhysics")
	var player_height = player.get_node("CollisionShape3D").shape.height
	var local_placement = Vector3.UP * 0.5 * player_height
	var marker_pos = player.to_global(local_placement)

	place_marker(player, marker_pos)


func place_marker(collider, pos):
	var marker = sphere.duplicate()
	collider.add_child(marker)
	marker.name = "PositionMarker"
	marker.owner = collider
	marker.global_position = pos
	selected_objects.append(collider)
	markers.append(marker)
