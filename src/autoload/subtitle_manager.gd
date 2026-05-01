extends Control


func _ready() -> void:
	hide()


func display(text: String) -> void:
	%Text.text = text
	show()
