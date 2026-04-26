class_name TeleporterManager
extends Node3D

## remove when inventory will be added
@onready var placer: ItemPlacer = $"../ItemPlacer"

#var marker: Marker = preload("res://shared/placer/marker.gd").instantiate()
const teleporter_scene = preload("res://shared/teleporters/teleporter.tscn")

@onready var teleporters = $Teleporters
@onready var input_window = $InputWindow

var camera: PlayerCamera


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("teleporter_place_mode"):
		placer.start_placing_next(teleporter_scene)
		print("placement started")


func create_teleporter(teleporter_instance):
	if not teleporter_instance is Teleporter:
		return
	teleporter_instance.reparent(teleporters)

	print(teleporter_instance.global_position)
	teleporter_instance.teleporter_name = await input_window.get_input("enter teleporter name")
	print("T name: " + teleporter_instance.teleporter_name)


func _physics_process(_delta: float) -> void:
	camera = get_node("../PlayerPhysics/PlayerCamera")

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
	var teleporter: Teleporter = collider.get_node_or_null("Teleporter")

	if not teleporter:
		return

	if Input.is_action_just_pressed("interact"):
		pass
		# show teleporter selection window
		# wait for selection
		# teleport
