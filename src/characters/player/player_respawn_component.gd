class_name PlayerRespawnComponent
extends Node

@export var health_component: HealthComponent
var player_scene = load("uid://c4sgtcvhksqls")
var animator: RespawnAnimator


func _ready():
	ProgressionManager.respawn_pos = get_node("../PlayerPhysics").global_position
	health_component.health_depleted.connect(_die)
	animator = CameraSetup.get_respawn_animator()
	animator.on_anim_finished.connect(_respawn)


func _die():
	ProgressionManager.record_death()
	if (!ProgressionManager.is_game_over()):
		animator._start()


func _respawn():
	get_parent().global_position = ProgressionManager.respawn_pos
	get_node("../PlayerPhysics").global_position = ProgressionManager.respawn_pos
	health_component.health = health_component.max_health
