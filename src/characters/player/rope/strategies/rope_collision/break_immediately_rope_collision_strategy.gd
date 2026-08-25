extends RopeCollisionStrategyInterface


func on_collision_entered(rope: Rope, _body: Node3D) -> void:
	rope.finish()

func on_collision_exited(_rope: Rope, _body: Node3D) -> void:
	pass
