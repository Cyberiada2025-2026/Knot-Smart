extends Node2D

@export var value_label: RichTextLabel

var active_sprite: Node2D


func _ready() -> void:
	Settings.debug_settings_random_value.updated.connect(update_label)
	update_label(Settings.debug_settings_random_value.value)


func update_label(value) -> void:
	value_label.text = str(value)


func _on_randomize_pressed() -> void:
	var random = RandomNumberGenerator.new()
	var new_value = snappedf(random.randf() * 100, 0.01)
	print("Randomize! (", new_value, ")")

	Settings.debug_settings_random_value.value = new_value


func _on_save_settings_pressed() -> void:
	print("Save settings!")
	SettingsManager.save_settings()


func _on_load_settings_pressed() -> void:
	print("Load settings!")
	SettingsManager.load_settings()



func _on_reset_settings_pressed() -> void:
	print("Reset settings!")
	SettingsManager.reset_settings()


func _on_spawn_pressed() -> void:
	print("Spawn!")
	if active_sprite:
		printerr("Cannot spawn - an active sprite already exists.")
		return

	active_sprite = load("res://scenes/debug/settings/settings_debug_sprite.tscn").instantiate()
	add_child(active_sprite)

	Settings.debug_settings_random_value.updated.connect(active_sprite.update_label)
	active_sprite.update_label(Settings.debug_settings_random_value.value)

func _on_remove_from_tree_pressed() -> void:
	print("Remove from tree!")
	if not active_sprite or active_sprite.get_parent() == null:
		printerr("Cannot remove from tree - sprite does not exist or is already removed from tree.")
		return

	remove_child(active_sprite)


func _on_add_to_tree_pressed() -> void:
	print("Add to tree!")
	if not active_sprite or active_sprite.get_parent() == self:
		printerr("Cannot add to tree - sprite does not exist or is already in tree.")
		return

	add_child(active_sprite)


func _on_destroy_pressed() -> void:
	print("Destroy!")
	if not active_sprite:
		printerr("Cannot destroy - sprite does not exist.")
		return

	active_sprite.queue_free()
