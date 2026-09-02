@tool
class_name MusicPlayerArea
extends Node3D

const VISUALIZATION_MATERIAL = preload(
	"res://shared/point_of_interest/point_of_interest_visualization_material.tres"
)

@export var radius: float = 0.5:
	set(value):
		radius = value
		collider.shape.radius = radius
		visualization_mesh.mesh.radius = radius
		visualization_mesh.mesh.height = radius * 2

@export var visualize: bool = true:
	set(value):
		visualize = value
		visualization_mesh.visible = visualize

@export var trigger_group_name: StringName = "Player"
@export var soundtrack: AudioStream
@export var disable_on_leave: bool = true

var area
var collider
var visualization_mesh


func _init():
	area = Area3D.new()
	collider = CollisionShape3D.new()
	visualization_mesh = MeshInstance3D.new()

	add_child(area)
	area.body_entered.connect(_on_area_3d_body_entered)
	area.body_exited.connect(_on_area_3d_body_exited)

	area.add_child(collider)
	collider.shape = SphereShape3D.new()
	# set player's collision layer
	area.set_collision_mask_value(2, true)
	area.set_collision_layer_value(1, false)

	area.add_child(visualization_mesh)
	visualization_mesh.mesh = SphereMesh.new()
	visualization_mesh.mesh.material = VISUALIZATION_MATERIAL


func _on_area_3d_body_entered(body: Node3D) -> void:
	var entity = body.get_parent()
	if entity.is_in_group(trigger_group_name):
		var music_player: MusicPlayer= entity.get_node("MusicPlayer")
		if not music_player.areas_disabled:
			music_player.set_soundtrack(soundtrack)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not disable_on_leave:
		return
	var entity = body.get_parent()
	if entity.is_in_group(trigger_group_name):
		var music_player: MusicPlayer = entity.get_node("MusicPlayer")
		if not music_player.areas_disabled:
			music_player.set_soundtrack(null)
