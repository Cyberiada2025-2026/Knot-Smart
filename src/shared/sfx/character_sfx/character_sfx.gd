extends Node3D

var character: CharacterBody3D

func _ready() -> void:
	character = self.get_parent()
