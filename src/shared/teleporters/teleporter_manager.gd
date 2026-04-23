class_name TeleporterManager
extends Node3D

## remove when inventory will be added
@onready var placer = $ItemPlacer


#var marker: Marker = preload("res://shared/placer/marker.gd").instantiate()
const teleporter_scene = preload("res://shared/teleporters/teleporter.tscn")

@onready var teleporters = $Teleporters
@onready var input_window = $InputWindow

var camera: PlayerCamera


func _physics_process(_delta: float) -> void:
	marker.hide()
	if not camera:
		camera = get_node("../PlayerPhysics/PlayerCamera")

				#PlayerCamera.
				#print("toggled")
		State.SELECTING_POSITION:
			if (
				camera.get_view_type() != PlayerCamera.ViewType.THIRD_PERSON
				or Input.is_action_just_pressed("teleporter_place_mode")
				or Input.is_action_just_pressed("pause_button")
			):
				set_idle()
				return

			var raycast_result = (
				UnsafeRaycastBuilder.new(self)
					.set_screen_position(get_viewport().get_mouse_position())
					.raycast()
			)

			if raycast_result.is_empty():
				return

			var player_position = get_node("../PlayerPhysics/").position

			if _3d_to_2d(player_position).distance_to(_3d_to_2d(raycast_result.position)) > placement_range:
				#print("too far away")
				var y = raycast_result.position.y
				raycast_result.position = (raycast_result.position - player_position).normalized() * placement_range + player_position
				raycast_result.position.y = y
				#print(UnsafeRaycastBuilder.new(self).camera)
				raycast_result = (
					UnsafeRaycastBuilder.new(self)
						.set_screen_position(UnsafeRaycastBuilder.new(self).camera.unproject_position(raycast_result.position))
						.raycast()
				)
				if raycast_result.is_empty():
					return
				#hit_normal = raycast_result.normal

			var hit_normal = raycast_result.normal
			# avoid too big angles
			var slope_angle_rad = hit_normal.angle_to(Vector3.UP)
			var slope_angle_deg = rad_to_deg(slope_angle_rad)
			if slope_angle_deg > max_placement_angle:
				return

			# add half box height instead of 0.5
			raycast_result.position += 0.5 * raycast_result.normal # fix box height to avoid being in textures

			marker.global_position = raycast_result.position
			marker.quaternion = Quaternion(Vector3.UP, raycast_result.normal)

			marker.update_state(raycast_result.collider)

			marker.show()

			if Input.is_action_just_pressed("left_mouse") and marker.allows_teleporter_placement:
				var teleporter_instance: Teleporter = teleporter_scene.instantiate()
				#teleporter_instance.global_transform.origin = Vector3(x * 3, 0, z * 3)
				teleporters.add_child(teleporter_instance)
				teleporter_instance.global_position = raycast_result.position
				teleporter_instance.quaternion = marker.quaternion

				# add teleporter name
				teleporter_instance.teleporter_name = await input_window.get_input("enter teleporter name")
				print("T name:")
				print(teleporter_instance.teleporter_name)

				#teleporter_instance.global_position.y += 0.5

				print(teleporter_instance.global_position)
				#get_tree().root.add_child(teleporter_instance)

				set_idle()


func _3d_to_2d(vector: Vector3) -> Vector2:
	return Vector2(vector.x, vector.z)
