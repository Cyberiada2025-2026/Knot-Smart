class_name ObjectDescription
extends Node3D

enum Pages { ITEMS = 1, OBJECTS, MOBS }

##Insert model of an object
@export var model: Node3D
##Type name of an object
@export var object_name: String
##Insert description of the object
@export var description: String
##Set at what page the object should be
@export var page: Pages = Pages.ITEMS
##Set the scale of an object
@export var object_scale: float = 0.5
##Set the radius of point of interest
@export var radius: float = 1.0
##Check if point of interest mesh should be visible
@export var poi_visible: bool = true


func _init() -> void:
	var poi: PointOfInterest = PointOfInterest.new()
	poi.noticed.connect(on_object_notice)
	poi.radius = radius
	poi.visualize = poi_visible
	add_child(poi)


func on_object_notice() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	var journal: Node = player.get_node("Journal")
	model = model.duplicate(0)
	journal.add_object(self)
	self.queue_free()
