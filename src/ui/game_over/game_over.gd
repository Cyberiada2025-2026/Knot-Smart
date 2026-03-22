extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_main_menu_button_pressed():
	SceneManager.goto_scene("uid://c62pp8s4uhak7")
