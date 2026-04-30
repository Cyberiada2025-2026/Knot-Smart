class_name JournalEntryPOI
extends Node

@export_category("Journal entry information")
## Name of an object
@export var object_name: String
## Description of the object
@export_multiline() var description: String
## What page the object should be at
@export_enum("Items:1", "Objects:2", "Mobs:3") var page

@export_category("Model information")
## Model of visible in an entry
@export var model: Node3D
## Scale of the model 
@export var model_scale: float = 0.5
## Angle in radians that object should rotate by per second.
@export var rotation_angle: float = 0.1


func _ready() -> void:
	var poi: PointOfInterest = get_parent() as PointOfInterest
	if poi == null:
		push_warning("JournalEntryPOI will not work without a PointOfInterest as a parent.")
		return

	poi.triggered.connect(on_object_notice)


func on_object_notice(_entity: Node3D) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var journal: Node = player.get_node("Journal")
	model = model.duplicate(0)
	journal.add_object(self)
	self.queue_free()
