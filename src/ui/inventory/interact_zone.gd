extends Area3D


signal interact_zone_entered
signal interact_zone_exited



func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body.name, " has entered")
	if body.name == "PlayerPhysics":
		interact_zone_entered.emit()
	
	
func _on_area_3d_body_exited(body: Node3D) -> void:
	print(body.name, " has exited")
	if body.name == "PlayerPhysics":
		interact_zone_exited.emit()
