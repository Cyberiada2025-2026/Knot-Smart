class_name ObjectDescription
extends Node3D

##Insert model of an object
@export var model: Node3D
##Type name of an object
@export var object_name: String
##Insert description of the object
@export var description: String
##Set at what page the object should be
@export_enum("Items", "Objects ", "Mobs") var set_page
##Set the scale of an object
@export var object_scale: float = 0.5
##Set the radius of point of interest
@export var radius: float = 1.0
##Check if point of interest mesh should be visible
@export var poi_visible: bool = true
##Angle in radians that object should rotate by.
@export var rotation_angle: float = 0.1

var page
var page_dict = {
	0: "Page container/Page2/ScrollContainer/VBoxContainer",
	1: "Page container/Page3/ScrollContainer/VBoxContainer",
	2: "Page container/Page4/ScrollContainer/VBoxContainer"
}


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
	page = page_dict[set_page]
	journal.add_object(self)
	self.queue_free()
