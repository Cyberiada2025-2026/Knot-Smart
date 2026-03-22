class_name DeathComponent
extends Node
## Despawns parent node when _on_death is called.


func _on_death() -> void:
	var parent = get_parent()
	parent.queue_free()
