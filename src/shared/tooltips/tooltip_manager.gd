class_name TooltipManager
extends Node3D

var _vbox: VBoxContainer
var _text_container: RichTextLabel

func _ready() -> void:
	_vbox = $Control/VBoxContainer
	_text_container = $Control/VBoxContainer/TooltipText
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(_delta: float) -> void:
	var camera = get_node("../PlayerPhysics/PlayerCamera")

	if (
		camera.get_view_type() == PlayerCamera.ViewType.FIRST_PERSON
		and not get_tree().paused
	):
		var raycast_result = (
			UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()
		)

		if not raycast_result.is_empty():
			var collider: Node3D = raycast_result.collider
			var tooltip: Tooltip = collider.find_child("Tooltip")

			if tooltip:
				_vbox.global_position = _vbox.get_global_mouse_position() + tooltip.offset
				_vbox.global_position.y -= _vbox.size.y
				_text_container.text = tooltip.message
				toggle(true)
				return
	toggle(false)


func toggle(on: bool):
	if on:
		$Control.show()
	else:
		$Control.hide()
