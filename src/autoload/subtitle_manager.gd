extends Control


func _ready() -> void:
	hide()


func display(text: String, duration_sec: float) -> void:
	%Text.text = text
	show()
	await get_tree().create_timer(duration_sec).timeout
	hide()
