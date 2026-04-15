class_name TeleporterManager
extends Node3D

enum State { IDLE, SELECTING_POSITION }

@export var placement_range: float = 3
## maximum surface angle in degrees which allows teleporter placement
@export var max_placement_angle = 20

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
				#print("toggled")
		State.SELECTING_POSITION:
			if (
				camera.get_view_type() != PlayerCamera.ViewType.THIRD_PERSON
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


			#var md = MeshDataTool.new()
			#var collider: Node3D = raycast_result.collider
			var hit_normal = raycast_result.normal
			#var mesh = $MeshInstance3D.mesh
			# Assumes you are working on the first surface (0)
			#md.create_from_surface(mesh, 0)

			# Retrieve normal of a specific vertex (e.g., vertex 0)
			#var vertex_normal = md.get_vertex_normal(0)


			#var surface_normal = raycast_result.get_normal()
			#print("Normal: ", hit_normal)

			# avoid too big angles
			var slope_angle_rad = hit_normal.angle_to(Vector3.UP)
			var slope_angle_deg = rad_to_deg(slope_angle_rad)
			if slope_angle_deg > max_placement_angle:
				return

			var player_position = get_node("../PlayerPhysics/").position

			if player_position.distance_to(raycast_result.position) > placement_range:
				print("too far away")
				return
				var y = raycast_result.position.y
				raycast_result.position = (raycast_result.position - player_position).normalized() * placement_range + player_position
				raycast_result.position.y = y
				#raycast_result.position *= placement_range / player_position.distance_to(raycast_result.position)
				#print(player_position.distance_to(raycast_result.position))
			#print(position)
			## lookat
			#look_at()
			#print(player_position)
			#print(raycast_result.position)
			#print("t")
			raycast_result.position += 0.5 * hit_normal # fix box height to avoid being in textures
			marker.global_position = raycast_result.position
			marker.quaternion = Quaternion(Vector3.UP, hit_normal)

			marker.show()

			if(Input.is_action_just_pressed("left_mouse")):
				var teleporter_instance = teleporter_scene.instantiate()
				#teleporter_instance.global_transform.origin = Vector3(x * 3, 0, z * 3)
				add_child(teleporter_instance)
				teleporter_instance.global_position = raycast_result.position

				#teleporter_instance.global_position.y += 0.5

				print(teleporter_instance.global_position)
				#get_tree().root.add_child(teleporter_instance)

				set_idle()


func set_idle():
	Input.set_mouse_mode(prev_mouse_mode)
	state = State.IDLE
