@tool
class_name PointOfInterest
extends Node3D

signal noticed

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

## message to say after triggering point of interest
@export_multiline var message: String

var collider
var visualization_mesh


func _init():
	var area = Area3D.new()
	collider = CollisionShape3D.new()
	visualization_mesh = MeshInstance3D.new()

	add_child(area)
	area.body_entered.connect(_on_area_3d_body_entered)

	area.add_child(collider)
	collider.shape = SphereShape3D.new()

	area.add_child(visualization_mesh)
	visualization_mesh.mesh = SphereMesh.new()
	visualization_mesh.mesh.material = VISUALIZATION_MATERIAL


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent().is_in_group(trigger_group_name):
		print(message)
		noticed.emit()
		self.queue_free()
