class_name EnemySpawnManager
extends Node3D

@export var min_spawn_distance_to_player: float
@export var max_spawn_distance_to_player: float
@export var despawn_distance: float
@export var nav_region: NavigationRegion3D

@export var debug_log: bool = false

var spawn_areas: Array[EnemySpawnArea]
var player: Player
var day_night_cycle: DayNightCycle

var active_enemy: Node3D

func _ready() -> void:
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


func spawn_enemy() -> void:
	var rand_point = Utils.get_random_point_in_circular_ring(min_spawn_distance_to_player, max_spawn_distance_to_player, player.player_physics.global_position)
	var rand_point_on_mesh = NavigationServer3D.region_get_closest_point(nav_region.get_rid(), rand_point)
	if debug_log:
		print("Random enemy spawnpoint picked: ", rand_point, ". After cast: ", rand_point_on_mesh)

	var picked_spawn_area: EnemySpawnArea = get_spawn_area()
	if picked_spawn_area == null:
		print("Player is outside any spawn area. Failed to spawn an enemy.")
		return

	var enemy: Node3D = picked_spawn_area.enemy_scene.instantiate()
	add_child(enemy)
	enemy.position = rand_point_on_mesh
	active_enemy = enemy
	if debug_log:
		print("Spawned enemy: %s at point: %s" % [enemy.name, rand_point_on_mesh])



func get_spawn_area() -> EnemySpawnArea:
	var active_spawn_areas: Array[EnemySpawnArea] = spawn_areas.filter(func(a): return a.overlaps_body(player.player_physics))
	return active_spawn_areas.pick_random() if not active_spawn_areas.is_empty() else null


func despawn_enemy() -> void:
	if active_enemy == null:
		return

	active_enemy.queue_free()
	active_enemy = null

	if debug_log:
		print("Despawning enemy")
	

func _on_time_period_changed(current: TimePeriod) -> void:
	if current.is_night:
		spawn_enemy()
	else:
		despawn_enemy()


func _physics_process(_delta: float) -> void:
	if active_enemy == null:
		return
	if active_enemy.global_position.distance_squared_to(player.player_physics.global_position) >= despawn_distance:
		despawn_enemy()
