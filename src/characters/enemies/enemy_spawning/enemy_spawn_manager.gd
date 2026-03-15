class_name EnemySpawnManager
extends Node3D

@export var min_spawn_distance_to_player: float
@export var max_spawn_distance_to_player: float
@export var despawn_distance: float
@export var nav_region: NavigationRegion3D
@onready var spawn_attempt_interval_timer: Timer = $"./SpawnAttemptInterval"
@export var max_spawn_attemts: int = 2
@export var max_active_enemies: int = 2

@export var debug_log: bool = false

var spawn_areas: Array[EnemySpawnArea]
var player: Player
var day_night_cycle: DayNightCycle

var active_enemies: Array[Node3D]

func _ready() -> void:
	spawn_attempt_interval_timer.timeout.connect(_on_spawn_interval_timeout)
	spawn_areas.assign(find_children("", "EnemySpawnArea"))

	var dnc_group = get_tree().get_nodes_in_group("day_night_cycle")
	if not dnc_group.is_empty():
		day_night_cycle = dnc_group[0]
		day_night_cycle.time_period_changed.connect(_on_time_period_changed)
		print("connected tpc")
	else:
		push_warning("No DayNightCycle found for EnemySpawnManager.")

	var player_group = get_tree().get_nodes_in_group("Player")
	if not player_group.is_empty():
		player = player_group[0]
	else:
		push_warning("No Player found for EnemySpawnManager.")


func get_spawn_point():
	var rand_point = Utils.get_random_point_in_circular_ring(min_spawn_distance_to_player, max_spawn_distance_to_player, player.player_physics.global_position)
	var rand_point_on_mesh = NavigationServer3D.region_get_closest_point(nav_region.get_rid(), rand_point)
	if rand_point_on_mesh.distance_squared_to(player.player_physics.global_position) >= pow(min_spawn_distance_to_player, 2):
		return rand_point_on_mesh
	return null


func spawn_enemy() -> bool:
	var rand_point_on_mesh = get_spawn_point()
	if rand_point_on_mesh == null:
		print("No valid spawn point found.")
		return false
	if debug_log:
		print("Random enemy spawnpoint picked: ", rand_point_on_mesh)

	var picked_spawn_area: EnemySpawnArea = get_spawn_area()
	if picked_spawn_area == null:
		print("Player is outside any spawn area. Failed to spawn an enemy.")
		return false

	var enemy: Node3D = picked_spawn_area.enemy_scene.instantiate()
	add_child(enemy)
	enemy.position = rand_point_on_mesh
	active_enemies.push_back(enemy)
	if debug_log:
		print("Spawned enemy: %s at point: %s" % [enemy.name, rand_point_on_mesh])

	return true



func get_spawn_area() -> EnemySpawnArea:
	var active_spawn_areas: Array[EnemySpawnArea] = spawn_areas.filter(func(a): return a.overlaps_body(player.player_physics))
	return active_spawn_areas.pick_random() if not active_spawn_areas.is_empty() else null


func despawn_enemy(enemy: Node3D) -> void:
	enemy.queue_free()
	active_enemies.erase(enemy)

	if debug_log:
		print("Despawning enemy: ", enemy)
	

func _on_time_period_changed(current: TimePeriod) -> void:
	if current.is_night:
		spawn_attempt_interval_timer.start()
	else:
		spawn_attempt_interval_timer.stop()
		for enemy in active_enemies.duplicate():
			despawn_enemy(enemy)
			


func _physics_process(_delta: float) -> void:
	for enemy in active_enemies:
		if enemy.global_position.distance_squared_to(player.player_physics.global_position) >= pow(despawn_distance,2):
			print("enemy out of range: ", enemy)
			despawn_enemy(enemy)



func _on_spawn_interval_timeout() -> void:
	if len(active_enemies) >= max_active_enemies:
		return
	for i in max_spawn_attemts:
		if spawn_enemy():
			break
