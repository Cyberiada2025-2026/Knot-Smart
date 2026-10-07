class_name ActorUtils
extends Node


static func get_point_on_map(point: Vector3) -> Vector3:
	var world = Engine.get_main_loop().root.get_world_3d()
	return NavigationServer3D.map_get_closest_point(world.get_navigation_map(), point)


static func get_random_point_near(point_position: Vector3, maximum_range: float) -> Vector3:
	var random_point = Utils.get_random_point_in_circular_ring(0.0, maximum_range, point_position)

	return get_point_on_map(random_point)


static func rotate_random(node: Node3D) -> void:
	var random := RandomNumberGenerator.new()
	var rotation: Vector3 = node.get_global_rotation()
	rotation.y = random.randi() % 360
	node.set_global_rotation(rotation)


static func set_random_nav_target_near(
	point_position: Vector3, maximum_range: float, navigation_agent: NavigationAgent3D
):
	navigation_agent.set_target_position(get_random_point_near(point_position, maximum_range))
