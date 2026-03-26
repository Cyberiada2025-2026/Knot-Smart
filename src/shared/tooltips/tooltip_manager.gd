class_name TooltipManager
extends Node3D

#var player: Player

var opacity_tween: Tween = null

#delet
#func _ready() -> void:
	#player = get_tree().get_first_node_in_group("Player")
	#if player == null:
		#printerr("player not found, can't use tooltips without player")
#/delet


func _ready() -> void:
	$Control.hide()
	
	
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
				$Control/VBoxContainer/TooltipText.text = tooltip.message
				toggle(true)
			#var parent = collider.ge
			#var pos_2d = camera.uncas	
			else:
				toggle(false)
		else:
			toggle(false)


func toggle(on: bool):
	if on:
		$Control.show()
		#$Control.modulate.a = 0.0
		#tween_opacity(1.0)
	else: 
		#$Control.modulate.a = 1.0
		#await tween_opacity(0.0).finished
		$Control.hide()
		

func tween_opacity(to: float):
	if opacity_tween: 
		opacity_tween.kill()
	opacity_tween = $Control.get_tree().create_tween()
	opacity_tween.tween_property($Control, "modulate:a", to, 0.5)
	return opacity_tween
