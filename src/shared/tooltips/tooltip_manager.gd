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

	$Control.hide()
	if (
		camera.get_view_type() != PlayerCamera.ViewType.FIRST_PERSON
		or get_tree().paused
	):
		return

	var raycast_result = (
		UnsafeRaycastBuilder.new(self).enable_collisions_with_areas().raycast()
	)

	if raycast_result.is_empty():
		return

	var collider: Node3D = raycast_result.collider
	var tooltip: Tooltip = collider.get_node_or_null("Tooltip")

	if not tooltip:
		return

	_vbox.global_position = _vbox.get_viewport_rect().size / 2 + tooltip.offset
	_vbox.global_position.y -= _vbox.size.y
	_text_container.text = tooltip.message
	$Control.show()
