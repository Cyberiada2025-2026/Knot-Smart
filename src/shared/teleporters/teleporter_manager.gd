class_name TeleporterManager
extends Node3D

## remove when inventory will be added
@onready var placer: ItemPlacer = $"../ItemPlacer"

const teleporter_scene = preload("res://shared/teleporters/teleporter.tscn")
const teleporter_button_scene = preload("res://shared/teleporters/teleporter_button.tscn")

@onready var teleporters = $Teleporters
@onready var input_window: InputWindow = $InputWindow
@onready var teleporter_buttons = $TeleporterSelectionWindow/Control/VBoxContainer2/ScrollContainer/VBoxContainer
@onready var teleporter_selection_window = $TeleporterSelectionWindow/Control

# onready runs before camera load
var camera: PlayerCamera


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("teleporter_place_mode"):
		placer.start_placing_next(teleporter_scene)
	if Input.is_action_just_pressed("pause_button"):
		teleporter_selection_window.hide()


func create_teleporter(teleporter_instance):
	if not teleporter_instance is Teleporter:
		return
	teleporter_instance.reparent(teleporters)

	teleporter_instance.teleporter_name = await input_window.get_input("enter teleporter name")
	var button: Button = teleporter_button_scene.instantiate()
	teleporter_buttons.add_child(button)
	button.text = teleporter_instance.teleporter_name

	button.button_down.connect(teleport.bind(teleporters.get_child_count() - 1))


func _physics_process(_delta: float) -> void:
	if not camera:
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
	var teleporter = collider.get_parent()

	if not teleporter is Teleporter:
		return

	if Input.is_action_just_pressed("interact"):
		PauseController.pause_game()
		teleporter_selection_window.show()


func teleport(teleporter_id: int):
	teleporter_selection_window.hide()
	var destination_teleporter = teleporters.get_child(teleporter_id)
	var player_physics = get_node("../PlayerPhysics/")
	player_physics.global_position = destination_teleporter.global_position
	# await to avoid input read from other classes
	await get_tree().process_frame
	PauseController.unpause_game()
