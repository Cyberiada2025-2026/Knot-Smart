extends Node3D


func _ready() -> void:
	$BiomeGenerator.generate()
	#$BiomeGenerator.show_debug()
