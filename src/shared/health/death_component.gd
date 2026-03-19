class_name DeathComponent
extends Node
## Despawns parent node on health_depleted

@export var health_component: HealthComponent


func _ready() -> void:
	health_component.health_depleted.connect(_on_health_depleted)


func _on_health_depleted() -> void:
	var parent = get_parent()
	print(parent, " killed")
	parent.queue_free()
