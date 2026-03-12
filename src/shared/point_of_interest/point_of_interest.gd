@tool
extends Node
class_name PointOfInterest

@export var radius: float = 2:
	set(value):
		radius = value
		if collider is CollisionShape3D:
			collider.shape.radius = radius
		if visualization_mesh is MeshInstance3D:
			visualization_mesh.mesh.radius = radius
			visualization_mesh.mesh.height = radius * 2
			
			
@export var visualize: bool = true:
	set(value):
		visualize = value
		if visualization_mesh is MeshInstance3D:
			visualization_mesh.visible = visualize
			
			
@export var trigger_group_name: StringName = "Player"

## message to say after triggering point of interest
@export_multiline var message: String;

## variable to avoiding doube-triggering
var triggered: bool = false

## scene to add if empty node is created in editor
var scene = preload("res://shared/point_of_interest/point_of_interest.tscn")

var collider
var visualization_mesh

func _ready():
	# replace node with scene added to scene as node
	if get_children().is_empty():
		var scene_instance = scene.instantiate()
		get_parent().add_child(scene_instance)
		scene_instance.name = self.name
		scene_instance.owner = get_parent()
		self.queue_free()
		return
	collider = $Area3D/CollisionShape3D
	visualization_mesh = $Area3D/MeshInstance3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not triggered and body.get_parent().is_in_group(trigger_group_name):
		triggered = true
		print(message)
		visualization_mesh.visible = false;
