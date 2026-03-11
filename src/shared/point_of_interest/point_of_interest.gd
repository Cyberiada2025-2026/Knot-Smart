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
			
			
