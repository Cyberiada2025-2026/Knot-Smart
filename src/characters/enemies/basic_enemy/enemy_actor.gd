class_name EnemyActor
extends CharacterBody3D

@export var speed := 5.0
@export var idle_wander_distance := 20
@export var push_force: float = 1.0
@export var default_search_distance: float = 10.0

var can_move := false
var world: World3D
var target: Node3D
var should_track_target: bool = false

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D


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


func is_group_member_nearby(
	group_name: StringName, desired_dist: float = default_search_distance
) -> bool:
	var nodes = get_tree().get_nodes_in_group(group_name)
	for node in nodes:
		var dist := global_position.distance_to(node.global_position)
		if dist < desired_dist:
			return true

	return false


func get_closest_target(group_name: StringName) -> Node3D:
	var nodes = get_tree().get_nodes_in_group(group_name)
	var closest_distance: float = INT32_MAX
	var closest_index: int = -1
	for i in nodes.size():
		var distance := global_position.distance_to(nodes[i].global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i

	if closest_index == -1:
		return null
	return nodes[closest_index]


func get_target_pos() -> Vector3:
	return navigation_agent_3d.get_target_position()


func set_velocity_to_target() -> void:
	var current_location := global_transform.origin
	var next_location := navigation_agent_3d.get_next_path_position()
	velocity = current_location.direction_to(next_location) * speed


func rotate_with_velocity() -> void:
	var velocity_2d = Vector3(velocity.x, 0, velocity.z)
	if velocity_2d.length_squared() > 0:
		look_at(global_position + velocity_2d)


func benchmark() -> void:
	for i in range(1000):
		get_closest_target("Player");

func push_rigid_bodies() -> void:
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
