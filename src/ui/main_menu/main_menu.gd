extends Control

@export_file_path(".tscn") var main_scene

func _on_play_button_pressed():
	SceneManager.goto_scene(main_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
