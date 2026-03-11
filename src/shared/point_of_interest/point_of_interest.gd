@tool
extends Node3D

@onready var collider = $Area3D/CollisionShape3D
@onready var visualization_mesh = $Area3D/MeshInstance3D

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


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not triggered and body.get_parent().is_in_group(trigger_group_name):
		triggered = true
		print(message)
		visualization_mesh.visible = false;
