extends Control

@export var tab_container: TabContainer


func _ready():
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		_reset_tab_container()

func _unhandled_input(event):
	if event is InputEventKey and event.is_action("pause_button") and event.is_pressed() and visible:
		_close_settings_window()
		get_viewport().set_input_as_handled()
			

func _reset_tab_container():
	# delete tab container and create it anew, under the same parent
	var tab_container_parent = tab_container.get_parent()
	var tab_container_path = tab_container.scene_file_path
	var tab_container_current_tab = tab_container.current_tab
	
	tab_container.queue_free()
	tab_container = load(tab_container_path).instantiate()
	tab_container_parent.add_child(tab_container)
	tab_container.current_tab = tab_container_current_tab


func _close_settings_window():
	Settings.load_settings()
	hide()

func switch_to_tab(tab_idx):
	tab_container.current_tab = posmod(tab_idx, tab_container.get_tab_count())

func _on_back_pressed():
	_close_settings_window()


func _on_reset_pressed():
	Settings.load_settings()
	_reset_tab_container()


func _on_save_pressed():
	Settings.save_settings()


func _on_default_pressed():
	Settings.reset_settings()
	_reset_tab_container()
