class_name TooltipManager
extends Node3D

var vbox: VBoxContainer
var text_container: RichTextLabel

func _ready() -> void:
	vbox = $Control/VBoxContainer
	text_container = $Control/VBoxContainer/TooltipText
	
	
func _physics_process(_delta: float) -> void:
	var raycast_result
	var camera = get_node("../PlayerPhysics/PlayerCamera")
	
	if (
		camera.get_view_type()
		== PlayerCamera.ViewType.FIRST_PERSON
	):
		raycast_result = UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()
	
		if not raycast_result.is_empty():
			var collider: Node3D = raycast_result.collider
			var tooltip: Tooltip = collider.find_child("Tooltip")
			
			if tooltip:
				vbox.global_position = vbox.get_global_mouse_position() + tooltip.offset
				vbox.global_position.y -= vbox.size.y
				text_container.text = tooltip.message
				toggle(true)
				return
	toggle(false)


func toggle(on: bool):
	if on:
		$Control.show()
	else: 
		$Control.hide()
