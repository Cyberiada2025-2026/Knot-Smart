class_name TooltipManager
extends Node3D

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if player == null:
		printerr("player not found, can't use tooltips without player")


func _physics_process(_delta: float) -> void:
	var raycast_result
	var camera = get_node("../PlayerPhysics/PlayerCamera")
	
	if (
		camera.get_view_type()
		== PlayerCamera.ViewType.FIRST_PERSON
	):
		raycast_result = UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()
	
		if not raycast_result.is_empty():
			var collider:Node3D = raycast_result.collider
			var tooltip: Tooltip = collider.find_child("Tooltip")
			#var distance = collider.position.distance_to(get_node("../PlayerPhysics").position)
			#print(distance)
			if tooltip != null:
				#print(tooltip.message)
				#tooltip.set_scale(Vector2(1 - distance / 10, 1 - distance / 10)) 
				tooltip.show()
			#var parent = collider.ge
			#var pos_2d = camera.uncas	
