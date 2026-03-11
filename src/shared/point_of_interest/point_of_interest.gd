@tool
extends Node

@onready var shapecast = $ShapeCast3D
@onready var visualization_mesh = $MeshInstance3D

@export var radius: float = 3:
	set(value):
		radius = value
		if shapecast is ShapeCast3D:
			shapecast.shape.radius = radius
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

var triggered: bool = false

func is_group_member_nearby() -> bool:
	if shapecast.is_colliding():
		for i in range(shapecast.get_collision_count()):
			var hit: Node3D = shapecast.get_collider(i)
				
			# it works, but should be changed
			if hit.get_parent().name == trigger_group_name:
				return true
	return false
	
func _physics_process(_delta: float) -> void:
	if not triggered and is_group_member_nearby():
		triggered = true
		print(message)
		visualization_mesh.visible = false;
