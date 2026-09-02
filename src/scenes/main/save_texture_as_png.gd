@tool
extends Node

@export var terrain_params: TerrainParams

@export_tool_button("Save as png") var save_action = save_noise

func save_noise():
	terrain_params.noise.get_image().save_png("res://shared/terrain/assets/terrain_noise.png")
