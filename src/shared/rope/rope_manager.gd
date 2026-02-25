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
