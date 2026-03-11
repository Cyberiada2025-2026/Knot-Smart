class_name Utils
extends Node

# Vector3i.Axis doesn't have its dictionary equavalent, so the redefinition is necessary
enum Axis {
	X = Vector3i.Axis.AXIS_X,
	Y = Vector3i.Axis.AXIS_Y,
	Z = Vector3i.Axis.AXIS_Z,
}


## Unsafe: Has to be called from within _physics_process.
## Performs a ray-cast from the position on ctx's viewport.
static func unsafe_raycast_from_screen_pos(
	ctx: Node3D, position: Vector2, ray_length = 1000.0
) -> Dictionary:
	var camera = ctx.get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(position)
	var normal = camera.project_ray_normal(position)
	var to = from + normal * ray_length

	var space_state = ctx.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	return result


## Unsafe: Has to be called from within _physics_process.
## Performs a ray-cast from the center of ctx's viewport
static func unsafe_raycast_from_screen_center(ctx: Node3D, ray_length = 1000.0) -> Dictionary:
	var viewport = ctx.get_viewport()
	var camera = viewport.get_camera_3d()
	var center_pos = viewport.size / 2
	return unsafe_raycast_from_screen_pos(ctx, center_pos, ray_length)
