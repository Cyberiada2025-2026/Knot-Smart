class_name PlayerRespawnComponent
extends Node

@export var health_component: HealthComponent
var player_scene = load("uid://c4sgtcvhksqls")


func _ready():
	ProgressionManager.respawn_pos = get_node("../PlayerPhysics").global_position
	health_component.health_depleted.connect(_die)


func _die():
	ProgressionManager.record_death()
	_respawn()


func _respawn():
	get_parent().global_position = ProgressionManager.respawn_pos
	get_node("../PlayerPhysics").global_position = ProgressionManager.respawn_pos
	health_component.health = health_component.max_health
