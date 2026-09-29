extends Node2D

@export var label: RichTextLabel

var _time = 0

func _process(delta: float) -> void:
	_time += delta
	position.x = sin(_time) * 100 + 100
	position.y = cos(_time) * 100 + 100

func update_label(new_value) -> void:
	print("- updating sprite label to: ", new_value)
	label.text = str(new_value)
