extends Node2D

@export var value_label: RichTextLabel
@export var item_list: ItemList

var active_sprite: Node2D


func _ready() -> void:
	value_label.add_child(SettingsListener.new(
		["debug scenes", "settings_debug", "random value"], update_label, true)
	)
	
	item_list.select(0)


func update_label(value) -> void:
	value_label.text = str(value)


func _on_randomize_pressed() -> void:
	var random = RandomNumberGenerator.new()
	var new_value = snappedf(random.randf() * 100, 0.01)
	print("Randomize! (", new_value, ")")
	
	Settings.set_value(["debug scenes", "settings_debug", "random value"], new_value)


func _on_save_settings_pressed() -> void:
	print("Save settings!")
	Settings.save_settings()


func _on_load_settings_pressed() -> void:
	print("Load settings!")
	Settings.load_settings()


func _on_spawn_pressed() -> void:
	print("Spawn! (lifetime=", item_list.get_item_text(item_list.get_selected_items()[0]), ")")
	if active_sprite:
		printerr("Cannot spawn - an active sprite already exists.")
		return
	
	active_sprite = load("res://scenes/debug/settings/settings_debug_sprite.tscn").instantiate()
	add_child(active_sprite)
	
	var lifetime: SettingsListener.Lifetime
	
	var lifetime_mode_idx = item_list.get_selected_items()[0]
	if item_list.get_item_text(lifetime_mode_idx) == "NODE_LIFETIME":
		lifetime = SettingsListener.Lifetime.NODE_LIFETIME
	elif item_list.get_item_text(lifetime_mode_idx) == "ONLY_IN_TREE":
		lifetime = SettingsListener.Lifetime.ONLY_IN_TREE
	else:
		return

	active_sprite.add_child(
		SettingsListener.new(
			["debug scenes", "settings_debug", "random value"],
			active_sprite.update_label,
			true,
			lifetime
		)
	)


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
