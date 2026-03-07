class_name RopeManager
extends Node3D


enum State {SELECT_FIRST, SELECT_SECOND}
var state = State.SELECT_FIRST


var rope_mode_toggle = false
var rope_points = []

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
				var marker = sphere.duplicate()
				result.collider.add_child(marker)
				marker.name = "PositionMarker"
				marker.owner = result.collider
				marker.global_transform = sphere.transform

				rope_points.append(result)
				state = State.SELECT_SECOND
		State.SELECT_SECOND:
			if Input.is_action_just_pressed("left_mouse"):
				var marker = sphere.duplicate()
				result.collider.add_child(marker)
				marker.name = "PositionMarker"
				marker.owner = result.collider
				marker.global_transform = sphere.transform

				rope_points.append(result)
				state = State.SELECT_SECOND

				var p1 = rope_points.pop_back()
				var p2 = rope_points.pop_back()
				var mark1 = p1.collider.find_child("PositionMarker*")
				var pos1 = mark1.global_position
				p1.collider.remove_child(mark1)
				mark1.queue_free()

				var mark2 = p2.collider.find_child("PositionMarker*")
				var pos2 = mark2.global_position
				p2.collider.remove_child(mark2)
				mark2.queue_free()

				var rope = Rope.new(pos1, p1.collider, pos2, p2.collider)
				add_child(rope)
				state = State.SELECT_FIRST
