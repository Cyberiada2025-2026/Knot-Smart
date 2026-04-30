class_name ObjectDescription
extends Node3D

@export_category("Journal entry information")
##Insert model of an object
@export var model: Node3D
##Type name of an object
@export var object_name: String
##Insert description of the object
@export var description: String
##Set at what page the object should be
@export_enum("Items:1", "Objects:2", "Mobs:3") var page
@export_category("Point of interest information")
##Set the radius of point of interest
@export var radius: float = 1.0
##Check if point of interest mesh should be visible
@export var poi_visible: bool = true
@export_category("Model information")
##Set the scale of an object
@export var object_scale: float = 0.5
##Angle in radians that object should rotate by.
@export var rotation_angle: float = 0.1


func _ready() -> void:
	var poi: PointOfInterest = get_parent() as PointOfInterest
	if poi == null:
		push_warning("ObjectDescriptionPOI will not work without a PointOfInterest as a parent.")
		return

	poi.triggered.connect(on_object_notice)


func on_object_notice(_entity: Node3D) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var journal: Node = player.get_node("Journal")
	model = model.duplicate(0)
	journal.add_object(self)
	self.queue_free()
