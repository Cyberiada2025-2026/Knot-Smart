extends TabContainer

@export var setting_keys_to_generate: Array[String]

func _ready():
	_init_tabs()
	_init_settings()


func _init_tabs():
	var existing_tab_names = []
	for tab_idx in range(get_tab_count()):
		existing_tab_names.append(get_tab_control(tab_idx).name)
	
	for settings_key in setting_keys_to_generate:
		if settings_key not in existing_tab_names:
			var new_tab = ScrollContainer.new()
			new_tab.name = settings_key
			add_child(new_tab)
			new_tab.add_child(VBoxContainer.new())


func _init_settings():
	for tab_idx in range(get_tab_count()):
		var tab_node = get_tab_control(tab_idx)
		var key = tab_node.name
		print(key)
		var setting_paths = DictionaryUtilities.get_all_leaf_paths(
			Settings.get_value([key])
		)
		
		for setting_path in setting_paths:
			setting_path.insert(0, key)
			var setting_value = Settings.get_value(setting_path)
			
			var widget: Control
			match typeof(setting_value):
				TYPE_BOOL:
					widget = _create_checkbox(setting_path, setting_value)
				TYPE_INT, TYPE_FLOAT:
					widget = _create_spinbox(setting_path, setting_value)
				TYPE_STRING:
					widget = _create_line_entry(setting_path, setting_value)
				TYPE_ARRAY:
					widget = _create_array_entry(setting_path, setting_value)
				_:
					widget = _create_error_label(setting_path, setting_value)
					
			# child[0] is a VBoxContainer. We want to add widgets to that, not to ScrollContainer
			tab_node.get_child(0).add_child(widget)
					

func _create_container_with_label(setting_path: Array[String]) -> HBoxContainer:
	var container = HBoxContainer.new()
	var label = Label.new()
	label.text = setting_path[-1]
	container.add_child(label)
	return container

func _create_checkbox(setting_path: Array[String], setting_value: bool) -> Control:
	var container = _create_container_with_label(setting_path)
	
	var checkbox = CheckBox.new()
	checkbox.button_pressed = setting_value
	checkbox.toggled.connect(
		func(new_state: bool):
			Settings.set_value(setting_path, new_state)
	)
	container.add_child(checkbox)
	return container

func _create_spinbox(setting_path: Array[String], setting_value: float) -> Control:
	var container = _create_container_with_label(setting_path)
	
	var spinbox = SpinBox.new()
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.step = 0.5
	spinbox.value = setting_value
	
	spinbox.value_changed.connect(
		func(new_value: float):
			Settings.set_value(setting_path, new_value)
	)
	container.add_child(spinbox)
	return container

func _create_line_entry(setting_path: Array[String], setting_value: String) -> Control:
	var container = _create_container_with_label(setting_path)
	
	var entry = LineEdit.new()
	entry.text = setting_value
	
	entry.text_changed.connect(
		func(new_value: String):
			Settings.set_value(setting_path, new_value)
	)
	container.add_child(entry)
	return container
	
func _create_array_entry(setting_path: Array[String], setting_value: Array) -> Control:
	var container = _create_container_with_label(setting_path)
	
	var label = Label.new()
	label.self_modulate = Color.YELLOW
	label.text = str(setting_value) + " arrays are not supported yet"
	container.add_child(label)
	return container

func _create_error_label(setting_path: Array[String], setting_value: Variant) -> Control:
	var container = _create_container_with_label(setting_path)
	
	var label = Label.new()
	label.self_modulate = Color.RED
	label.text = str(setting_value) + " unsupported type: " + type_string(typeof(setting_value))
	container.add_child(label)
	return container
