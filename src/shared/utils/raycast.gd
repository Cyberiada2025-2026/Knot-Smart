## Unsafe: Can only be created and used during physics_process.
## A ray-casting utility. Defaults to ray-casts from screen center.
class_name UnsafeRaycastBuilder
extends Node

var space_state: PhysicsDirectSpaceState3D
var camera: Camera3D
var screen_pos: Vector2
var ray_length = 1000.0


## Unsafe: Can only be created during physics_process.
## [param context]: A Node3D whose camera will be used for raycasting
func _init(context: Node3D) -> void:
	self.space_state = context.get_world_3d().direct_space_state
	var viewport = context.get_viewport()
	self.camera = viewport.get_camera_3d()
	self.screen_pos = viewport.size / 2


func set_ray_length(length: float) -> UnsafeRaycastBuilder:
	self.ray_length = length
	return self


func set_screen_position(position: Vector2) -> UnsafeRaycastBuilder:
	self.screen_pos = position
	return self


## Unsafe: Has to be called from within _physics_process.
## Builds a raycast query and performs it, then destroys the builder
func raycast() -> Dictionary:
	var from = camera.project_ray_origin(screen_pos)
	var normal = camera.project_ray_normal(screen_pos)
	var to = from + normal * ray_length
	var query = PhysicsRayQueryParameters3D.create(from, to)

	var result = space_state.intersect_ray(query)

	queue_free()
	return result
