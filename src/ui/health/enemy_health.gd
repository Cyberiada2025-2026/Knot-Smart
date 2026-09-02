extends TextureProgressBar

var health_component: HealthComponent
var max_health
var health

var camera: Camera3D
var enemy: Node3D

@export var enemy_height: int = 6


func _ready() -> void:
	camera = get_viewport().get_camera_3d().get_node(
		"Control/SubViewportContainer/SubViewport/MainCamera"
	)
	enemy = get_parent()
	health_component = enemy.get_node("HealthComponent")
	max_health = health_component.max_health
	health = health_component.health

	change_bar_size()

	health_component.health_decreased.connect(health_changed)
	health_component.health_increased.connect(health_changed)
	health_component.max_health_changed.connect(max_health_changed)


func _physics_process(_delta: float) -> void:
	#visible = not camera.is_position_behind(enemy.global_position + Vector3(0, enemy_height, 0))
	visible = camera.is_position_in_frustum(enemy.global_position) #and camera.is_position_in_frustum(enemy.global_position + Vector3(0, enemy_height, 0))
	var screen_pos = camera.unproject_position(enemy.global_position + Vector3(0, enemy_height, 0))
	global_position = screen_pos
	global_position += Vector2(-get_rect().size.x / 2, 0)
	var distance = camera.global_position.distance_to(enemy.global_position)

	var parent = get_parent()
	var camera_pos: Vector3 = camera.global_position
	var pos: Vector3 = parent.global_position
	var raycast_result = (
		UnsafeRaycastBuilder
		.new(parent)
		.set_direction((pos - camera_pos).normalized())
		.set_raycast_origin(camera_pos)
		.set_collision_mask(256)
		.enable_collisions_with_areas()
		.raycast()
	)

	if (
		distance<50
		and ((
			not raycast_result.is_empty()
			and raycast_result.collider.global_position.distance_to(camera_pos) >= distance
		)
		or raycast_result.is_empty()
		)

	):
		var scale_factor = clamp(pow(10.0 / distance, 1.5), 0.1, 0.7)
		scale = Vector2(scale_factor, scale_factor)
	else:
		visible = false


func change_bar_size():
	value = health / max_health * 100


func health_changed():
	health = health_component.health
	change_bar_size()


func max_health_changed():
	max_health = health_component.max_health
	change_bar_size()
