class_name Tooltip
extends Control

@export_multiline var message: String
#var player: Player
#
#func _ready() -> void:
	#player = get_tree().get_first_node_in_group("Player")
	#if player == null:
		#printerr("player not found, can't use tooltips without player")

@export var offset: Vector2

func _ready() -> void:
	$VBoxContainer/TooltipText.text = message
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + offset

func toggle(on: bool):
	if on:
		show()
	else:
		hide()
#func _physics_process(_delta: float) -> void:
	#var camera: PlayerCamera = player.get_node("PlayerPhysics/PlayerCamera")
	#if (
		#camera.get_view_type()
		#== PlayerCamera.ViewType.FIRST_PERSON
	#):
		#print("found")
