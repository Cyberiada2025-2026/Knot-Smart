class_name EnemyActor
extends CharacterBody3D

@export var speed := 5.0
@export var idle_wander_distance := 20
@export var push_force: float = 1.0

var can_move := false
var world: World3D
var target: Node3D
var should_track_target: bool = false

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var shapecast = $ShapeCast3D


func _ready() -> void:
	world = Engine.get_main_loop().root.get_world_3d()
	navigation_agent_3d.set_target_position(global_position)


func _physics_process(_delta: float) -> void:
	if can_move:
		set_velocity_to_target()
		rotate_with_velocity()
		move_and_slide()
		push_rigid_bodies()


func set_random_nav_target_near(point_position: Vector3) -> void:
	navigation_agent_3d.set_target_position(
		ActorUtils.get_random_point_near(point_position, idle_wander_distance)
	)


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
	var vel_2d = Vector3(velocity.x, 0, velocity.z)
	if vel_2d.length_squared() > 0:
		look_at(global_position + vel_2d)


func push_rigid_bodies() -> void:
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
