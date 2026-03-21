class_name DeathComponent
extends Node
## Despawns parent node on signal


func _on_death() -> void:
	var parent = get_parent()
	parent.queue_free()
