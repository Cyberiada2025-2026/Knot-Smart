@tool
class_name PointOfInterest
extends Node3D

signal triggered(entity: Node3D)

@export var radius: float = 0.5
@export var visualize: bool = true
@export var trigger_group_name: StringName = "Player"

var area: Area3D


func _init():
	area = Area3D.new()
	add_child(area)
	area.body_entered.connect(_on_area_3d_body_entered)

	var collider = CollisionShape3D.new()
	collider.shape = SphereShape3D.new()
	collider.shape.radius = radius
	area.add_child(collider)

	if visualize:
		var mesh = MeshInstance3D.new()
		mesh.mesh = SphereMesh.new()
		mesh.mesh.radius = radius
		mesh.mesh.height = radius * 2

		var material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.5, 0.9, 0.9, 0.2)
		mesh.mesh.material = material

		area.add_child(mesh)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group(trigger_group_name):
		triggered.emit(body)
		area.queue_free()
		if get_child_count() == 0:
			queue_free()
