extends AnimationPlayer


func _on_enemy_died() -> void:
	print("enemy died. map opened.")
	play("fall_down")

