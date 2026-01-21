extends CharacterBody3D

@export var speed := 30000
@onready var navigation_agent_3d : NavigationAgent3D = $NavigationAgent3D
@onready var shapecast = $ShapeCast3D

const IDLE_DIS := 20

var can_move := false
var world : World3D


func _ready() -> void:
	world =  Engine.get_main_loop().root.get_world_3d()


func get_random_point_near() -> Vector3:
	var random_point := global_position + Vector3(
		randf_range(-IDLE_DIS, IDLE_DIS),
		0,
		randf_range(-IDLE_DIS, IDLE_DIS)
	)

	return NavigationServer3D.map_get_closest_point(
		world.get_navigation_map(),
		random_point)


func set_random_direction() -> void:
	navigation_agent_3d.set_target_position(get_random_point_near())


func set_velocity_to_target() -> void:
	var cur_loc := global_transform.origin
	var next_loc := navigation_agent_3d.get_next_path_position()
	var next_vel := (next_loc - cur_loc).normalized() * speed
	velocity = next_vel


func toggle_movement(b: bool) -> void:
	can_move = b


func is_at_destination() -> bool:
	return navigation_agent_3d.is_target_reached()


func is_group_member_nearby (group_name: StringName) -> bool:
	shapecast.force_shapecast_update()

	if shapecast.is_colliding():
		for i in range(shapecast.get_collision_count()):
			var hit : Node3D = shapecast.get_collider(i)
			if hit.get_parent().is_in_group(group_name):
				return true
	return false


func get_object_around(group_name: StringName) -> Node3D:
	shapecast.force_shapecast_update()

	if shapecast.is_colliding():
		for i in range(shapecast.get_collision_count()):
			var hit : Node3D = shapecast.get_collider(i)
			if hit.get_parent().is_in_group(group_name):
				return hit.get_parent()
	return null


func get_target_pos() -> Vector3:
	return navigation_agent_3d.get_target_position()


func destroy_target(target_group: StringName) -> void:
	var target : Node3D = get_object_around(target_group)
	if (target != null):
		target.queue_free()


func _physics_process(_delta: float) -> void:
	if can_move:
		set_velocity_to_target()
		move_and_slide()


func attack() -> void:
	#we can use like seperate class attack for diffrent attack types
	print("attack!")
