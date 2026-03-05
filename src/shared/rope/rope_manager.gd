class_name RopeManager
extends Node3D

var rope_mode_toggle = false
var rope_points = []

const RAY_LENGTH = 1000.0
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
	var camera = CameraSingleton.get_main_camera()
	var center_pos = camera.get_viewport().size_2d_override / 2
	var from = camera.project_ray_origin(center_pos)
	var normal = camera.project_ray_normal(center_pos)
	var to = from + normal * RAY_LENGTH
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		sphere.hide()
	else:
		sphere.show()
		sphere.position = result["position"]
	
		if Input.is_action_just_pressed("left_mouse"):
			rope_mode_toggle = not rope_mode_toggle
			var marker = sphere.duplicate()
			result.collider.add_child(marker)
			marker.name = "PositionMarker"
			marker.owner = result.collider
			marker.global_transform = sphere.transform

			rope_points.append(result)

			if not rope_mode_toggle:
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
