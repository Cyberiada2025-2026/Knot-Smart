@tool
class_name PointOfInterest
extends Node3D

signal triggered(entity: Node3D)

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

var area
var collider
var visualization_mesh


func _init():
	area = Area3D.new()
	collider = CollisionShape3D.new()
	visualization_mesh = MeshInstance3D.new()

	add_child(area)
	area.body_entered.connect(_on_area_3d_body_entered)

	area.add_child(collider)
	collider.shape = SphereShape3D.new()

	area.add_child(visualization_mesh)
	visualization_mesh.mesh = SphereMesh.new()
	visualization_mesh.mesh.material = VISUALIZATION_MATERIAL


func _ready():
	child_order_changed.connect(_can_queue_free)


func _on_area_3d_body_entered(body: Node3D) -> void:
	var entity = body.get_parent()
	if entity.is_in_group(trigger_group_name):
		triggered.emit(entity)
		area.queue_free()
		_can_queue_free()


func _can_queue_free():
	if get_child_count() == 0:
		queue_free()
