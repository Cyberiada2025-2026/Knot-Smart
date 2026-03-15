class_name EnemySpawnManager
extends Node3D
## Controls the spawning and despawning of enemies around the player.
## In order to determine which enemy will be spawned it requires EnemySpawnAreas as its children.
## Will only spawn one enemy per EnemySpawnArea.

@export var debug_log: bool = false

@export_group("Spawn parameters")
@export var min_spawn_distance: float = 10.0
@export var max_spawn_distance: float = 20.0
@export var despawn_distance: float = 40.0
@export var max_active_enemies: int = 2
## Time between enemy spawn attempts.
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var spawn_attempt_interval: float = 5.0
## How many times enemy spawn is attempted per interval.
@export var spawn_attempt_count: int = 2

@export_group("References")
@export var nav_region: NavigationRegion3D
## Enemies will be spawned as children of this node.
@export var enemy_spawn_node: Node3D

var spawn_areas: Array[EnemySpawnArea]
var active_enemies: Dictionary[Area3D, Node3D]

var player: Player
var day_night_cycle: DayNightCycle
var spawn_attempt_timer: Timer


func _ready() -> void:
	spawn_attempt_timer = Timer.new()
	add_child(spawn_attempt_timer)
	spawn_attempt_timer.wait_time = spawn_attempt_interval
	spawn_attempt_timer.timeout.connect(_on_spawn_interval_timeout)

	spawn_areas.assign(find_children("", "EnemySpawnArea"))
	if spawn_areas.is_empty():
		push_warning("No EnemySpawnAreas found.")

	var dnc_group = get_tree().get_nodes_in_group("day_night_cycle")
	if dnc_group.is_empty():
		push_warning("No DayNightCycle found for EnemySpawnManager. No enemies will be spawned.")
		return

	day_night_cycle = dnc_group[0]
	day_night_cycle.time_period_changed.connect(_on_time_period_changed)

	var player_group = get_tree().get_nodes_in_group("Player")
	if player_group.is_empty():
		push_warning("No Player found for EnemySpawnManager. No enemies will be spawned.")
		return

	player = player_group[0]


func get_spawn_point():
	var rand_point = Utils.get_random_point_in_circular_ring(
		min_spawn_distance, max_spawn_distance, player.player_physics.global_position
	)
	var rand_point_on_mesh = NavigationServer3D.region_get_closest_point(
		nav_region.get_rid(), rand_point
	)
	if (
		rand_point_on_mesh.distance_squared_to(player.player_physics.global_position)
		>= pow(min_spawn_distance, 2)
	):
		return rand_point_on_mesh
	return null


func spawn_enemy() -> bool:
	var picked_spawn_area: EnemySpawnArea = get_spawn_area()
	if picked_spawn_area == null or active_enemies.has(picked_spawn_area):
		if debug_log:
			print("Failed to pick valid spawn area.")
		return false

	var rand_point_on_mesh = get_spawn_point()
	if rand_point_on_mesh == null:
		if debug_log:
			print("Failed to find valid spawn point.")
		return false

	var enemy: Node3D = picked_spawn_area.enemy_scene.instantiate()
	enemy_spawn_node.add_child(enemy)
	enemy.position = rand_point_on_mesh
	active_enemies.set(picked_spawn_area, enemy)

	if debug_log:
		print("Spawned enemy: %s at point: %s" % [enemy.name, rand_point_on_mesh])

	return true


func get_spawn_area() -> EnemySpawnArea:
	var active_spawn_areas: Array[EnemySpawnArea] = spawn_areas.filter(
		func(a): return a.overlaps_body(player.player_physics)
	)
	return active_spawn_areas.pick_random() if not active_spawn_areas.is_empty() else null


func despawn_enemy(enemy: Node3D) -> void:
	enemy.queue_free()
	active_enemies.erase(active_enemies.find_key(enemy))

	if debug_log:
		print("Despawned enemy: ", enemy)


func _on_time_period_changed(current: TimePeriod) -> void:
	if current.is_night:
		spawn_attempt_timer.start()
	else:
		spawn_attempt_timer.stop()
		for enemy in active_enemies.values():
			despawn_enemy(enemy)


func _physics_process(_delta: float) -> void:
	for enemy in active_enemies.values():
		if (
			enemy.global_position.distance_squared_to(player.player_physics.global_position)
			>= pow(despawn_distance, 2)
		):
			despawn_enemy(enemy)


func _on_spawn_interval_timeout() -> void:
	if active_enemies.size() >= max_active_enemies:
		return

	for i in spawn_attempt_count:
		if spawn_enemy():
			break
