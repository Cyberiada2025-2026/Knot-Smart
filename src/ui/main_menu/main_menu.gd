extends Control


func _on_play_button_pressed():
	SceneManager.goto_scene("uid://cwbuu8wnww8af")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
