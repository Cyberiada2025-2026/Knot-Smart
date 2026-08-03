class_name Pig
extends CharacterBody3D

@export var speed := 5.0
@export var idle_wander_distance := 20
@export var push_force: float = 1.0

var can_move := false
var world: World3D
var target: Node3D
var should_track_target: bool = false

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


func _ready() -> void:
	world = Engine.get_main_loop().root.get_world_3d()
	navigation_agent_3d.set_target_position(global_position)


func get_point_on_map(point: Vector3) -> Vector3:
	return NavigationServer3D.map_get_closest_point(world.get_navigation_map(), point)


func get_random_point_near(point_position: Vector3) -> Vector3:
	var random_point = Utils.get_random_point_in_circular_ring(
		0.0, idle_wander_distance, point_position
	)

	return get_point_on_map(random_point)


func set_random_nav_target_near(point_position: Vector3):
	navigation_agent_3d.set_target_position(get_random_point_near(point_position))


func get_target_pos() -> Vector3:
	return navigation_agent_3d.get_target_position()


func rotate_random() -> void:
	var random := RandomNumberGenerator.new()
	rotation.y = random.randi() % 360


func rotate_with_velocity() -> void:
	if velocity.length_squared() > 0:
		look_at(global_position + velocity)


func set_velocity_to_target() -> void:
	var cur_loc := global_transform.origin
	var next_loc := navigation_agent_3d.get_next_path_position()
	var next_vel := cur_loc.direction_to(next_loc) * speed
	velocity = next_vel


func _physics_process(_delta: float) -> void:
	if can_move:
		set_velocity_to_target()
		rotate_with_velocity()
		move_and_slide()
		push_rigid_bodies()


func push_rigid_bodies() -> void:
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
