class_name TeleporterManager
extends Node3D

enum State { IDLE, SELECTING_POSITION }

var state = State.IDLE
var marker: MeshInstance3D = preload("res://shared/teleporters/teleporter_placement_marker.tscn").instantiate()
const teleporter_scene = preload("res://shared/teleporters/teleporter.tscn")

var prev_mouse_mode


func _ready() -> void:
	add_child(marker)


func _physics_process(_delta: float) -> void:
	marker.hide()

	var camera = get_node("../PlayerPhysics/PlayerCamera")

	match state:
		State.IDLE:
			if (
				Input.is_action_just_pressed("teleporter_place_mode")
				and camera.get_view_type() == PlayerCamera.ViewType.THIRD_PERSON
			):
				state = State.SELECTING_POSITION
				prev_mouse_mode = Input.get_mouse_mode()
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				print("toggled")
		State.SELECTING_POSITION:
			if (
				camera.get_view_type() != PlayerCamera.ViewType.THIRD_PERSON
				or get_tree().paused
			):
				return
			var raycast_result = (
				UnsafeRaycastBuilder.new(self).set_screen_position(get_viewport().get_mouse_position()).enable_collisions_with_areas().raycast()
			)

			if raycast_result.is_empty():
				return

			print(position)
			print(raycast_result.position)
			marker.position = raycast_result.position
			marker.show()

			if(Input.is_action_just_pressed("left_mouse")):
				var teleporter_instance = teleporter_scene.instantiate()
				teleporter_instance.position = raycast_result.position
				add_child(teleporter_instance)
				Input.set_mouse_mode(prev_mouse_mode)
				state = State.IDLE
