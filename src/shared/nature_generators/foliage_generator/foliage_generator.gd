@tool
class_name FoliageGenerator
extends Node3D

const DIR_PATH = "user://foliage"

var foliage: StaticBody3D
var foliage_scene: PackedScene


func serialize():
	add_child(Serialize.serialize(foliage_scene, foliage, DIR_PATH))
