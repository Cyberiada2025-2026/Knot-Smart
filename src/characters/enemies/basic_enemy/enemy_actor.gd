class_name EnemyActor
extends CharacterBody3D

@export var speed := 5.0
@export var idle_wander_distance := 20

var can_move := false
var world: World3D
var target: Node3D
var should_track_target: bool = false

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var shapecast = $ShapeCast3D


func _ready() -> void:
	world = Engine.get_main_loop().root.get_world_3d()


func get_point_on_map(point: Vector3) -> Vector3:
	return NavigationServer3D.map_get_closest_point(world.get_navigation_map(), point)


func get_random_point_near() -> Vector3:
	var random_point = Utils.get_random_point_in_circular_ring(
		0.0, idle_wander_distance, global_position
	)

	return get_point_on_map(random_point)


func set_random_direction() -> void:
	navigation_agent_3d.set_target_position(get_random_point_near())


func set_velocity_to_target() -> void:
	var cur_loc := global_transform.origin
	var next_loc := navigation_agent_3d.get_next_path_position()
	var next_vel := cur_loc.direction_to(next_loc) * speed
	velocity = next_vel


func is_group_member_nearby(group_name: StringName) -> bool:
	shapecast.force_shapecast_update()

	for i in shapecast.get_collision_count():
		var hit: Node3D = shapecast.get_collider(i)
		if hit.get_parent().is_in_group(group_name):
			return true
	return false


func get_object_around(group_name: StringName) -> Node3D:
	shapecast.force_shapecast_update()

	if shapecast.is_colliding():
		for i in range(shapecast.get_collision_count()):
			var hit: Node3D = shapecast.get_collider(i)
			if hit.get_parent().is_in_group(group_name):
				return hit.get_parent()
	return null


func get_target_pos() -> Vector3:
	return navigation_agent_3d.get_target_position()


func rotate_with_velocity() -> void:
	if velocity.length_squared() > 0:
		look_at(global_position + velocity)


func _physics_process(_delta: float) -> void:
	if can_move:
		set_velocity_to_target()
		rotate_with_velocity()
		move_and_slide()
