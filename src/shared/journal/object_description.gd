class_name ObjectDescription
extends Node

##Insert model of an object
@export var model: Node3D
##Type name of an object
@export var object_name: String
##Insert description of the object
@export var description: String
##Type at what page the object should be (3 - mobs, 2 - objects, 1 - items)
@export var page: int
##Set the scale of an object
@export var scale: float


func _init() -> void:
	var poi: PointOfInterest = PointOfInterest.new()
	poi.noticed.connect(on_object_notice)
	poi.radius = 1.0
	add_child(poi)


func on_object_notice() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	var journal: Node = players[0].get_node("Journal")
	var model_duplicate = model.duplicate(7)
	journal.add_object(description, object_name, model_duplicate, page, scale)
	self.queue_free()
