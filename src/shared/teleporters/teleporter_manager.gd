class_name TeleporterManager
extends Node3D

enum State { IDLE, SELECTING_POSITION }

const placement_range = 3

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
			):
				reset_prev_mouse_state()
				return

			var raycast_result = (
				UnsafeRaycastBuilder.new(self).set_screen_position(get_viewport().get_mouse_position()).enable_collisions_with_areas().raycast()
			)

			if raycast_result.is_empty():
				return

			var player_position = get_node("../PlayerPhysics/").position

			if player_position.distance_to(raycast_result.position) > placement_range:
				var y = raycast_result.position.y
				raycast_result.position = (raycast_result.position - player_position).normalized() * placement_range + player_position
				raycast_result.position.y = y
				#raycast_result.position *= placement_range / player_position.distance_to(raycast_result.position)
				print(player_position.distance_to(raycast_result.position))
			#print(position)
			## lookat
			print(player_position)
			#print(raycast_result.position)
			#print("t")
			raycast_result.position.y += 0.5
			marker.global_position = raycast_result.position
			marker.show()

			if(Input.is_action_just_pressed("left_mouse")):
				var teleporter_instance = teleporter_scene.instantiate()
				#teleporter_instance.global_transform.origin = Vector3(x * 3, 0, z * 3)
				add_child(teleporter_instance)
				teleporter_instance.global_position = raycast_result.position

				#teleporter_instance.global_position.y += 0.5

				print(teleporter_instance.global_position)
				#get_tree().root.add_child(teleporter_instance)

				reset_prev_mouse_state()


func reset_prev_mouse_state():
	Input.set_mouse_mode(prev_mouse_mode)
	state = State.IDLE
