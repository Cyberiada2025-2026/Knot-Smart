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

	if get_node("../PlayerCamera").get_view_type() == PlayerCamera.ViewType.THIRD_PERSON:
		return

	var result = UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()

	if result.is_empty():
		return

	sphere.position = result.position
	sphere.show()

	if result.collider.get_parent() is Rope:
		if Input.is_action_just_pressed("break_rope"):
			result.collider.get_parent().finish()

		elif Input.is_action_just_pressed("fuse"):
			result.collider.get_parent().fuse()

	match state:
		State.SELECT_FIRST:
			if Input.is_action_just_pressed("left_mouse"):
				place_marker_on_object(result.collider)
				state = State.SELECT_SECOND

		State.SELECT_SECOND:
			if Input.is_action_just_pressed("left_mouse"):
				place_marker_on_object(result.collider)

				var positions: Array[Vector3] = []
				for marker in markers:
					positions.append(marker.global_position)
				var rope = Rope.new(rope_params, selected_objects, positions)
				add_child(rope)

				selected_objects = []
				for marker in markers:
					marker.queue_free()
				markers = []

				state = State.SELECT_FIRST


func place_marker_on_object(collider):
	var marker = sphere.duplicate()
	collider.add_child(marker)
	marker.name = "PositionMarker"
	marker.owner = collider
	marker.global_transform = sphere.transform
	selected_objects.append(collider)
	markers.append(marker)
