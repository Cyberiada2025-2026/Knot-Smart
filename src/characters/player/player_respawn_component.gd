class_name PlayerRespawnComponent
extends Node

@export var health_component: HealthComponent


func _ready():
	ProgressionManager.respawn_pos = get_parent().position
	health_component.health_depleted.connect(_respawn)


func _respawn():
	ProgressionManager.record_death()
	health_component.health = health_component.max_health
	get_parent().position = ProgressionManager.respawn_pos
