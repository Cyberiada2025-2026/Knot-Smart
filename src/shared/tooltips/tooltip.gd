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

var opacity_tween: Tween = null

func _ready() -> void:
	$VBoxContainer/TooltipText.text = message
	hide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + offset


func toggle(on: bool):
	if on:
		show()
		modulate.a = 0.0
		tween_opacity(1.0)
	else: 
		modulate.a = 1.0
		await tween_opacity(0.0).finished
		hide()
		

func tween_opacity(to: float):
	if opacity_tween: 
		opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(self, "modulate:a", to, 0.3)
	return opacity_tween
	

#func _physics_process(_delta: float) -> void:
	#var camera: PlayerCamera = player.get_node("PlayerPhysics/PlayerCamera")
	#if (
		#camera.get_view_type()
		#== PlayerCamera.ViewType.FIRST_PERSON
	#):
		#print("found")
