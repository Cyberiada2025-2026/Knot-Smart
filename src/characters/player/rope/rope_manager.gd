class_name RopeManager
extends Node3D


enum State {SELECT_FIRST, SELECT_SECOND}
var state = State.SELECT_FIRST


var selected_objects = []
var markers = []

const RADIUS = 0.1

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

	var result = Utils.unsafe_raycast_from_screen_center(self)

	if result.is_empty():
		return

	sphere.position = result["position"]
	sphere.show()

	match state:
		State.SELECT_FIRST:
			if Input.is_action_just_pressed("left_mouse"):
				place_marker_on_object(result.collider)
				state = State.SELECT_SECOND

		State.SELECT_SECOND:
			if Input.is_action_just_pressed("left_mouse"):
				place_marker_on_object(result.collider)

				var obj1 = selected_objects.pop_back()
				var obj2 = selected_objects.pop_back()
				var mark1 = markers.pop_back()
				var pos1 = mark1.global_position
				obj1.remove_child(mark1)
				mark1.queue_free()

				var mark2 = markers.pop_back()
				var pos2 = mark2.global_position
				obj2.remove_child(mark2)
				mark2.queue_free()

				var rope = Rope.new(pos1, obj1, pos2, obj2)
				add_child(rope)
				state = State.SELECT_FIRST


func place_marker_on_object(collider):
	var marker = sphere.duplicate()
	collider.add_child(marker)
	marker.name = "PositionMarker"
	marker.owner = collider
	marker.global_transform = sphere.transform
	selected_objects.append(collider)
	markers.append(marker)
