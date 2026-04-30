class_name TextDescription
extends Node3D

##Insert text that will be added when player will enter this area
@export var text: String
##Insert the radius that point of interest will be
@export var radius: float = 1.0
##Should the point of interest be visible?
@export var poi_visible: bool = false


func _init() -> void:
	var poi: PointOfInterest = PointOfInterest.new()
	poi.triggered.connect(on_object_notice)
	poi.radius = radius
	poi.visualize = poi_visible
	add_child(poi)


func on_object_notice(_entity: Node3D) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var journal: Node = player.get_node("Journal")
	journal.add_text_entry(text)
	self.queue_free()
