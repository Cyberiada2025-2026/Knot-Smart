class_name ObjectDescription 
extends Node

##Insert model of an object
@export var Model: Node3D
##Insert name of an object
@export var Name: String
##Insert description of the object
@export var Description: String
##Insert number at which page the object should be (3 - mobs, 2 - objects, 1 - items)
@export var Page: int

func _init() -> void:
	var poi: PointOfInterest = PointOfInterest.new()
	poi.noticed.connect(on_object_notice)
	poi.radius=1.0
	add_child(poi)
	
func on_object_notice() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	var journal: Node = players[0].get_node("Journal")
	print("weee")
	var model_duplicate = Model.duplicate(7) 
	journal.add_object(Description, Name, model_duplicate, Page)
