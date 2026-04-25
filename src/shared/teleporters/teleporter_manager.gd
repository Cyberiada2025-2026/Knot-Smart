class_name TeleporterManager
extends Node3D

## remove when inventory will be added
@onready var placer: ItemPlacer = $ItemPlacer

#var marker: Marker = preload("res://shared/placer/marker.gd").instantiate()
const teleporter_scene = preload("res://shared/teleporters/teleporter.tscn")

@onready var teleporters = $Teleporters
@onready var input_window = $InputWindow

#var camera: PlayerCamera


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("teleporter_place_mode"):
		placer.start_placing_next(teleporter_scene)
		print("placement started")


func create_teleporter(teleporter_instance):
	teleporters.add_child(teleporter_instance)
	teleporter_instance.teleporter_name = await input_window.get_input("enter teleporter name")
	print("T name:")
