extends Node3D

var rope_mode_toggle = false
var rope_points = []

const RAY_LENGTH = 1000.0
const RADIUS = 0.1

@export var camera: Camera3D
var sphere: MeshInstance3D

func _ready() -> void:
	sphere = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.set_radius(RADIUS)
	mesh.set_height(2 * RADIUS)
	sphere.set_mesh(mesh)
	add_child(sphere)


func _physics_process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var normal = camera.project_ray_normal(mouse_pos)
	var to = from + normal * RAY_LENGTH
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		sphere.hide()
	else:
		sphere.show()
		sphere.position = result["position"]
	
		if Input.is_action_just_pressed("add_rope"):
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
				var mark1 = p1.collider.find_child("PositionMarker")
				var mark2 = p2.collider.find_child("PositionMarker")
				var rope = Rope.new(mark1.global_position, p1.collider, mark2.global_position, p2.collider)
				mark1.queue_free()
				mark2.queue_free()
				add_child(rope)
